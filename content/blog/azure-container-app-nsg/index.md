---
title: Minimal Network Security Group for Azure Container App
summary: This post provides a Terraform NSG configuration that enables Azure Container Apps to work properly while maintaining strict network security.
description: Azure, Container App, Terraform, DevOps, Cloud Computing, Infrastructure as Code, IaC
date: 2025-09-30
tags:
  - devops
  - azure
  - terraform
---

Azure [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) (NSGs) are firewall-like filters that control inbound and outbound network traffic to Azure resources by allowing you to define security rules based on source/destination IP addresses, ports, and protocols.

If you want to restrict your [Azure Container App's](https://learn.microsoft.com/en-us/azure/container-apps/overview) (CA) network traffic via NSGs you have to know that there are quite a number of destinations a CA must be able to reach in order to work properly[^1].

The following snippet shows a minimal NSG for a CA (with workload proiles):

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
