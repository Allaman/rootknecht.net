---
title: Minimale Netzwerksicherheitsgruppe für Azure Container App
summary: Dieser Beitrag enthält eine Terraform-NSG-Konfiguration, die Azure Container Apps ordnungsgemäß betreiben lässt und dabei strikte Netzwerksicherheit wahrt.
description: Azure, Container App, Terraform, DevOps, Cloud Computing, Infrastructure as Code, IaC
date: 2025-09-30
tags:
  - devops
  - azure
  - terraform
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/azure-container-app-nsg/)
{{< /alert >}}

Azure [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) (NSGs) sind firewall-ähnliche Filter, die den ein- und ausgehenden Netzwerkverkehr zu Azure-Ressourcen steuern, indem Sie Sicherheitsregeln basierend auf Quell-/Ziel-IP-Adressen, Ports und Protokollen definieren können.

Wenn man den Netzwerkverkehr seiner [Azure Container App](https://learn.microsoft.com/en-us/azure/container-apps/overview) (CA) über NSGs einschränken möchte, muss man wissen, dass es eine ganze Reihe von Zielen gibt, die eine CA erreichen können muss, um ordnungsgemäß zu funktionieren[^1].

Der folgende Ausschnitt zeigt eine minimale NSG für eine CA (mit Workload-Profilen):

```hcl
resource "azurerm_network_security_group" "app" {
  name                = "nsg-foo"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow inbound traffic from Load Balancer (for ingress)
  security_rule {
    name                       = "AllowLoadBalancerInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Allow inbound HTTPS traffic for ingress
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow internal communication within container apps subnet (inbound)
  security_rule {
    name                       = "AllowInternalInbound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.app.address_prefixes[0]
    destination_address_prefix = azurerm_subnet.app.address_prefixes[0]
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllOtherInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow internal communication within container apps subnet (outbound)
  security_rule {
    name                       = "AllowInternalOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.app.address_prefixes[0]
    destination_address_prefix = azurerm_subnet.app.address_prefixes[0]
  }

  # Allow outbound to Azure Container Registry
  security_rule {
    name                       = "AllowACROutbound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "MicrosoftContainerRegistry"
  }

  # Allow outbound to Azure Container Registry service
  security_rule {
    name                       = "AllowAzureContainerRegistryOutbound"
    priority                   = 121
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureContainerRegistry"
  }

  # Allow outbound DNS resolution (TCP)
  security_rule {
    name                       = "AllowDNSOutboundTCP"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "168.63.129.16/32"
  }

  # Allow outbound DNS resolution (UDP)
  security_rule {
    name                       = "AllowDNSOutboundUDP"
    priority                   = 131
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "168.63.129.16/32"
  }

  # Allow outbound to Azure Monitor
  security_rule {
    name                       = "AllowAzureMonitorOutbound"
    priority                   = 140
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureMonitor"
  }

  # Allow outbound to Azure Storage
  security_rule {
    name                       = "AllowAzureStorageOutbound"
    priority                   = 160
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Storage.<REGION>"
  }

  # Allow outbound to Azure FrontDoor
  security_rule {
    name                       = "AllowAzureFrontDoorOutbound"
    priority                   = 170
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureFrontDoor.FirstParty"
  }

  # Allow outbound to Azure Active Directory
  security_rule {
    name                       = "AllowAzureActiveDirectoryOutbound"
    priority                   = 180
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureActiveDirectory"
  }

  # Deny all other outbound traffic
  security_rule {
    name                       = "DenyAllOtherOutbound"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

[^1]: <https://learn.microsoft.com/en-us/azure/container-apps/firewall-integration?tabs=workload-profiles>
