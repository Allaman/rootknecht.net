---
title: Passwordless Azure PostgreSQL with Terraform and connection via Container App
summary: How to create an Azure PostgreSQL instance without public access and passwords using Terraform while ensuring security. Additionally, I will explain how to access this database from a container app using access tokens.
description: Azure, PostgreSQL, Terraform, DevOps, Database, cloud Computing, Infrastructure as Code, IaC, Python
date: 2024-01-27T13:00:25+10:00
tags:
  - devops
  - azure
  - database
  - terraform
---

## Azure PostgreSQL Primer

[Azure Database for PostgreSQL](https://azure.microsoft.com/en-us/products/postgresql/) is a Microsoft Azure service.

> [...] fully managed, intelligent, and scalable PostgreSQL.

So basically, someone runs a PostgreSQL database for you, and your operational burden is heavily reduced.

It must be distinguished between the [single](https://learn.microsoft.com/en-us/azure/postgresql/single-server/overview-single-server) server and the [flexible](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview) server. As the _single server is on the retirement path_, we will work with the flexible server in this post.

## Azure Container App Primer

[Azure Container App](https://azure.microsoft.com/en-us/products/container-apps) is an Azure service to

> Build and deploy fully managed, cloud-native apps and microservices using serverless containers.

So you just "throw" your containers in the cloud and don't even have to manage a "managed Kubernetes". :wink:

## Goals

1. Infrastructure as Code via Terraform. There is no manual configuration in the Azure Portal :nerd_face:
1. Use Microsoft Entra ID ([formerly known as Azure Active Directory](https://www.microsoft.com/de-de/security/business/identity-access/microsoft-entra-id)) for PostgreSQL authentication, more specifically [managed identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview). This enables us to not care about credentials as we use the onboard resources of the cloud.
1. There is no public access to the database. In our database, we store our crown jewels, so we must protect it from the evil internet.
1. Connect to the database from [Azure Container Apps](https://azure.microsoft.com/en-us/products/container-apps). Our application(s) must be able to communicate with our database. In this example, I have chosen container apps, but the method is similar for other computing services, e.g. a virtual machine.

## Prerequisites

I will not go into detail about how to set up your Azure cloud and subscription. Some basics should be ready:

- A vnet
- A resource group
- A working Terraform environment that can create resources in said resource group[^1]

## Creating the database

Let's begin with some code. Adjust the parameters to your needs!

First things first, we need to create some "auxiliary" resources:

### Subnet

```hcl
resource "azurerm_subnet" "db" {
  name                 = var.db_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  # smallest subnet size is /28
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
```

This will create a [delegated subnet](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking-private#virtual-network-concepts) for our database.

{{< alert >}}
The subnet's smallest size is /28 and the whole subnet is reserved for PostgreSQL services only. You cannot assign this subnet to a container app, for instance.
{{< /alert >}}

### DNS

Then, we need to create a private DNS zone and a virtual link linking our vnet and the DNS zone

```hcl
resource "azurerm_private_dns_zone" "db" {
  name                = "passwordless.private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}
```

{{< alert >}}
`.private.postgres.database.azure.com` is mandatory!
{{< /alert >}}

```hcl
resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "passwordless"
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}
```

### Database

Now, we can create the actual database

```hcl
data "azurerm_client_config" "current" {
}

resource "azurerm_postgresql_flexible_server" "db" {
  auto_grow_enabled            = var.auto_grow_enabled
  backup_retention_days        = var.backup_retention_days
  delegated_subnet_id          = azurerm_subnet.db.id
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  location                     = var.region
  private_dns_zone_id          = azurerm_private_dns_zone.db.id
  name                         = var.name
  resource_group_name          = var.resource_group_name
  sku_name                     = var.sku
  storage_mb                   = var.max_storage_mb
  version                      = var.engine_version
  authentication {
    password_auth_enabled         = false
    active_directory_auth_enabled = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#zone
  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone
    ]
  }
}
```

This is the key part of the former snippet!

```hcl{linenos=true}
  authentication {
    password_auth_enabled         = false
    active_directory_auth_enabled = true
    tenant_id                     = var.tenant_id
  }
```

Line 2 disables the PostgreSQL authentication (no backdoor :winking_face_with_tongue:), and line 3 enables Microsoft Entra ID authentication (former Azure Active Directory).

Finally, create a database.

```hcl
resource "azurerm_postgresql_flexible_server_database" "project" {
  charset    = var.db_charset
  collation  = var.db_collation
  name       = var.db_name
  server_id  = azurerm_postgresql_flexible_server.db.id
}
```

If everything works as expected, you should now have the following resources:

- a delegated subnet for PostgreSQL flexible servers
- a private DNS zone linked to your vnet
- a PostgreSQL server with one database

But how can you authenticate to your fresh database, you might ask? Let's check the container app to answer this question.

## Creating the container app

First, we create a managed identity. This identity is used to create an admin user for our database and is assigned to our container app.

### Managed identity

{{< alert >}}
To create a non-admin user, you must be able to run a SQL statement ([How to Create Users](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-create-users)) against your database. Either via Terraform (null_resource and local-exec) or just via a PostgreSQL client of your choice. For both methods, you have to "open" a network route to your database. In this example, I assume that the only database user is the admin user and that all security considerations are known and accepted.
{{< /alert >}}

```hcl
resource "azurerm_user_assigned_identity" "pgadmin" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
```

### PostgreSQL admin

```hcl
data "azurerm_client_config" "current" {
}
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin" {
  server_name         = azurerm_postgresql_flexible_server.db.name
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_user_assigned_identity.pgadmin.principal_id
  principal_name      = azurerm_user_assigned_identity.pgadmin.identity_name
  principal_type      = "ServicePrincipal"
}
```

### Container App

For the sake of brevity, I will trim the container app snippet to the relevant parts.

```hcl
resource "azurerm_container_app" "app" {
  name = var.name
  env  = [
    {
      name  = "DB_USER"
      value = azurerm_user_assigned_identity.pgadmin.identity_name
    },
    {
      name  = "DB_FQDN"
      value = azurerm_postgresql_flexible_server.db.fqdn
    },
    {
      name  = "DB_NAME"
      value = var.db_name
    },
    # https://learn.microsoft.com/en-us/answers/questions/1225865/unable-to-get-a-user-assigned-managed-identity-wor
    {
      name  = "AZURE_CLIENT_ID"
      value = azurerm_user_assigned_identity.pgadmin.client_id
    }
  ]
  identity {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.pgadmin.id]
    }
}
```

We provide the container app with the created identity, which also serves as a PostgreSQL admin. Additionally, it is important to mention that we define environment variables with the necessary parameters to establish a connection to the database. One benefit of utilizing a managed identity is that there is no requirement to define an environment variable `DB_PASSWORD` since we acquire an access token for the database, as you will soon witness.

{{< alert >}}
Terraform stores those values ([traditionally](https://github.com/hashicorp/terraform/issues/516) :laughing:) in plain text in its state, so from this point of view, it is also a major win to not have to define a password!
{{< /alert >}}

If everything works as expected, you should now have the following resources:

- a managed identity
- a database administrator
- a container app

In the following part, I describe how to finally connect to the database.

## Connecting to the database

Now, how can you connect to the database from your container app? First, I will describe how to use the traditional `postgresql-client` and bash, and then provide a small Python example. In this case, I was running a `debian:12-slim` container with `sleep infinity` as the CMD, so that the container would not shut down immediately. Your experience may differ with different images (such as Alpine, Python, etc.).

### Bash

We install the necessary packages, then query the metadata service to get an access token[^2], and finally connect to our database via psql.

```bash
apt update && apt install -y curl jq postgresql-client
export PGPASSWORD=$(curl -sH "X-IDENTITY-HEADER: $IDENTITY_HEADER" \
"http://localhost:42356/msi/token?api-version=2019-08-01&resource=https%3A%2F%2Fossrdbms-aad.database.windows.net&client_id=$AZURE_CLIENT_ID" | \
jq -r .access_token)
psql -h $DB_FQDN --user $DB_USER $DB_NAME
```

### Python

The following steps are necessary to set up a minimal python environment:

```bash
apt install libpq-dev python3 python3-pip python3.11-venv
python3 -m venv test
cd test
source bin/activate
pip install psycopg2-binary azure-identity
```

The Python script to connect to the database:

```python
# main.py
import datetime
import os
import psycopg2
from azure.identity import DefaultAzureCredential

# Read required parameters from the ENV
host = os.environ["DB_FQDN"]
user = os.environ["DB_USER"]
db = os.environ["DB_NAME"]

# Fetch an access token with the default (and only) managed identity assigned to the container app
azure_credential = DefaultAzureCredential()
print("Fetch access token.")
token = azure_credential.get_token("https://ossrdbms-aad.database.windows.net/.default")
expires = datetime.datetime.fromtimestamp(token.expires_on)
print(f"Access token expires at {expires}")

# Create the connection string and connect to the database
conn_string = (
    f"host={host} user={user} dbname={db} password={token.token} sslmode=require"
)
conn = psycopg2.connect(conn_string)
print("Connection established")
```

Just run it via `python main.py`.

[^1]: Tested with Terraform `1.5` and azurerm `v3.86`.
[^2]: I was unable to run `az login --identity` due to an error that I can't recall.
