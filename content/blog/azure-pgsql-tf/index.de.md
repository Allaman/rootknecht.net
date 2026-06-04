---
title: Passwortloses Azure PostgreSQL mit Terraform und mit Container Apps verbinden
summary: Wie man eine Azure-PostgreSQL-Instanz ohne öffentlichen Zugang und ohne Passwörter mit Terraform erstellt und dabei die Sicherheit gewährleistet. Außerdem erkläre ich, wie man von einer Container App aus mit Access Tokens auf diese Datenbank zugreift.
description: Azure, PostgreSQL, Terraform, DevOps, Datenbank, Cloud Computing, Infrastructure as Code, IaC, Python
date: 2024-01-27T13:00:25+10:00
tags:
  - devops
  - azure
  - database
  - terraform
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/azure-pgsql-tf/)
{{< /alert >}}

## Azure PostgreSQL im Überblick

[Azure Database for PostgreSQL](https://azure.microsoft.com/en-us/products/postgresql/) ist ein Microsoft-Azure-Dienst.

> [...] fully managed, intelligent, and scalable PostgreSQL.

Im Grunde betreibt jemand eine PostgreSQL-Datenbank für einen, und der eigene Betriebsaufwand wird erheblich reduziert.

Es muss zwischen dem [Single](https://learn.microsoft.com/en-us/azure/postgresql/single-server/overview-single-server)-Server und dem [Flexible](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview)-Server unterschieden werden. Da _der Single Server auf dem Weg zur Stilllegung ist_, wird in diesem Beitrag mit dem Flexible Server gearbeitet.

## Azure Container App im Überblick

[Azure Container App](https://azure.microsoft.com/en-us/products/container-apps) ist ein Azure-Dienst zum

> Erstellen und Bereitstellen vollständig verwalteter, cloud-nativer Apps und Microservices mit serverlosen Containern.

Man „wirft" seine Container einfach in die Cloud und muss nicht einmal ein „managed Kubernetes" verwalten. :wink:

## Ziele

1. Infrastructure as Code via Terraform. Es gibt keine manuelle Konfiguration im Azure-Portal. :nerd_face:
1. Microsoft Entra ID ([früher bekannt als Azure Active Directory](https://www.microsoft.com/de-de/security/business/identity-access/microsoft-entra-id)) für die PostgreSQL-Authentifizierung nutzen, genauer gesagt [Managed Identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview). Damit müssen wir uns keine Gedanken über Zugangsdaten machen, da wir die integrierten Cloud-Ressourcen nutzen.
1. Kein öffentlicher Zugang zur Datenbank. In der Datenbank werden die Kronjuwelen gespeichert, also muss sie vor dem bösen Internet geschützt werden.
1. Verbindung zur Datenbank von [Azure Container Apps](https://azure.microsoft.com/en-us/products/container-apps) aus herstellen. Die Anwendungen müssen mit der Datenbank kommunizieren können. In diesem Beispiel habe ich Container Apps gewählt, aber die Methode ist für andere Computing-Dienste, z. B. eine virtuelle Maschine, ähnlich.

## Voraussetzungen

Ich werde nicht im Detail erklären, wie man seine Azure-Cloud und sein Abonnement einrichtet. Einige Grundlagen sollten vorhanden sein:

- Ein VNet
- Eine Ressourcengruppe
- Eine funktionierende Terraform-Umgebung, die Ressourcen in der genannten Ressourcengruppe erstellen kann[^1]

## Die Datenbank erstellen

Fangen wir mit etwas Code an. Die Parameter nach Bedarf anpassen!

Zunächst müssen einige „Hilfsressourcen" erstellt werden:

### Subnetz

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

Damit wird ein [delegiertes Subnetz](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking-private#virtual-network-concepts) für die Datenbank erstellt.

{{< alert >}}
Die kleinste Subnetzgröße ist /28, und das gesamte Subnetz ist ausschließlich für PostgreSQL-Dienste reserviert. Dieses Subnetz kann z. B. keiner Container App zugewiesen werden.
{{< /alert >}}

### DNS

Dann muss eine private DNS-Zone und ein virtueller Link erstellt werden, der das VNet und die DNS-Zone verbindet:

```hcl
resource "azurerm_private_dns_zone" "db" {
  name                = "passwordless.private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}
```

{{< alert >}}
`.private.postgres.database.azure.com` ist obligatorisch!
{{< /alert >}}

```hcl
resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "passwordless"
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}
```

### Datenbank

Nun kann die eigentliche Datenbank erstellt werden:

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

Dies ist der entscheidende Teil des obigen Ausschnitts!

```hcl{linenos=true}
  authentication {
    password_auth_enabled         = false
    active_directory_auth_enabled = true
    tenant_id                     = var.tenant_id
  }
```

Zeile 2 deaktiviert die PostgreSQL-Authentifizierung (keine Hintertür :winking_face_with_tongue:), und Zeile 3 aktiviert die Microsoft Entra ID-Authentifizierung (früher Azure Active Directory).

Zum Abschluss wird eine Datenbank erstellt:

```hcl
resource "azurerm_postgresql_flexible_server_database" "project" {
  charset    = var.db_charset
  collation  = var.db_collation
  name       = var.db_name
  server_id  = azurerm_postgresql_flexible_server.db.id
}
```

Wenn alles wie erwartet funktioniert, sollten jetzt folgende Ressourcen vorhanden sein:

- ein delegiertes Subnetz für PostgreSQL Flexible Server
- eine private DNS-Zone, die mit dem VNet verknüpft ist
- ein PostgreSQL-Server mit einer Datenbank

Wie man sich nun bei der frischen Datenbank authentifiziert, beantwortet der folgende Abschnitt zur Container App.

## Die Container App erstellen

Zunächst wird eine Managed Identity erstellt. Diese Identity wird verwendet, um einen Admin-Benutzer für die Datenbank zu erstellen, und der Container App zugewiesen.

### Managed Identity

{{< alert >}}
Um einen Nicht-Admin-Benutzer zu erstellen, muss man eine SQL-Anweisung ([How to Create Users](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-create-users)) gegen die Datenbank ausführen können. Entweder über Terraform (null_resource und local-exec) oder direkt über einen PostgreSQL-Client. Für beide Methoden muss eine Netzwerkroute zur Datenbank geöffnet werden. In diesem Beispiel wird davon ausgegangen, dass der einzige Datenbankbenutzer der Admin-Benutzer ist und dass alle Sicherheitsaspekte bekannt und akzeptiert sind.
{{< /alert >}}

```hcl
resource "azurerm_user_assigned_identity" "pgadmin" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
```

### PostgreSQL-Admin

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

Der Kürze halber beschränke ich den Container-App-Ausschnitt auf die relevanten Teile.

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

Der Container App wird die erstellte Identity zugewiesen, die gleichzeitig als PostgreSQL-Admin dient. Außerdem werden Umgebungsvariablen mit den notwendigen Parametern für die Datenbankverbindung definiert. Ein Vorteil der Managed Identity ist, dass keine Umgebungsvariable `DB_PASSWORD` definiert werden muss, da ein Access Token für die Datenbank abgerufen wird, wie gleich zu sehen sein wird.

{{< alert >}}
Terraform speichert diese Werte ([traditionellerweise](https://github.com/hashicorp/terraform/issues/516) :laughing:) im Klartext in seinem State-File. Von diesem Gesichtspunkt aus ist es daher ein großer Vorteil, kein Passwort definieren zu müssen!
{{< /alert >}}

Wenn alles wie erwartet funktioniert, sollten jetzt folgende Ressourcen vorhanden sein:

- eine Managed Identity
- ein Datenbankadministrator
- eine Container App

Im folgenden Teil wird beschrieben, wie die Verbindung zur Datenbank schließlich hergestellt wird.

## Verbindung zur Datenbank herstellen

Wie stellt man von der Container App aus eine Verbindung zur Datenbank her? Zunächst beschreibe ich die Nutzung des traditionellen `postgresql-client` und Bash, dann folgt ein kleines Python-Beispiel. In diesem Fall wird ein `debian:12-slim`-Container mit `sleep infinity` als CMD ausgeführt, damit der Container nicht sofort heruntergefahren wird. Die Erfahrung kann mit anderen Images (wie Alpine, Python usw.) abweichen.

### Bash

Es werden die notwendigen Pakete installiert, dann wird der Metadatendienst abgefragt, um ein Access Token zu erhalten[^2], und schließlich wird die Verbindung zur Datenbank über psql hergestellt.

```bash
apt update && apt install -y curl jq postgresql-client
export PGPASSWORD=$(curl -sH "X-IDENTITY-HEADER: $IDENTITY_HEADER" \
"http://localhost:42356/msi/token?api-version=2019-08-01&resource=https%3A%2F%2Fossrdbms-aad.database.windows.net&client_id=$AZURE_CLIENT_ID" | \
jq -r .access_token)
psql -h $DB_FQDN --user $DB_USER $DB_NAME
```

### Python

Die folgenden Schritte sind notwendig, um eine minimale Python-Umgebung einzurichten:

```bash
apt install libpq-dev python3 python3-pip python3.11-venv
python3 -m venv test
cd test
source bin/activate
pip install psycopg2-binary azure-identity
```

Das Python-Skript zur Verbindung mit der Datenbank:

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

Einfach mit `python main.py` ausführen.

[^1]: Getestet mit Terraform `1.5` und azurerm `v3.86`.

[^2]: Ich war nicht in der Lage, `az login --identity` aufgrund eines Fehlers auszuführen, den ich nicht mehr rekonstruieren kann.
