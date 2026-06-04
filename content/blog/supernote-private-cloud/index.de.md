---
title: Erster Blick auf die Supernote Private Cloud
summary: Einrichtung einer self-hosted Supernote Private Cloud mit Docker Compose und Nginx.
description: produktivität, E-Ink, Notizen, Supernote A5X2 Manta, Self-Hosting, Docker
date: 2025-11-14
tags:
  - produktivität
  - self-hosted
  - docker
  - eink
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/supernote-private-cloud/)
{{< /alert >}}

Mit der kürzlichen Veröffentlichung von [Chauvet 3.25.39](https://supernote.com/blogs/supernote-blog/private-cloud-for-data-sovereignty-serverlink-for-remote-files-control-via-webdav) für Supernote Manta und Nomad wurde die Option eingeführt, die Cloud für die Synchronisation selbst zu hosten.

In diesem Blogbeitrag werfe ich einen Blick auf das [Deployment mit Docker-Containern (PDF)](https://ib.supernote.com/private-cloud/Supernote-Private-Cloud-Manual-Deployment-Method-Using-Docker-Containers.pdf). Ein „manuelles" (Linux/Synology NAS) Deployment ist ebenfalls [verfügbar (PDF)](https://ib.supernote.com/private-cloud/Supernote-Private-Cloud-Deployment-Manual.pdf).

## Docker

Bei der Durchsicht des verlinkten Dokuments war ich etwas enttäuscht, dass keine Compose-Datei bereitgestellt wurde, also bat ich mein bevorzugtes LLM, eine für mich zu schreiben.

Das nächste, was mich störte, waren die veralteten Verweise auf MariaDB und Redis auf Docker Hub. Ich beschloss, die offiziellen neuesten Docker-Images auszuprobieren, und sie funktionieren anscheinend auch.

Ich habe auch nur die Supernote-App-Ports exponiert und den Zugriff auf 127.0.0.1 anstelle von 0.0.0.0 beschränkt (für mein Reverse-Proxy-Setup).

Nach dem Herunterladen der SQL-Datei, die die Tabellenstruktur für die Datenbank erstellt:

```sh
curl -O https://supernote-private-cloud.supernote.com/cloud/supernotedb.sql
```

und dem Erstellen der Verzeichnisse zum Speichern von Daten und Konfiguration kann ich schließlich meine Cloud starten.

```sh
mkdir ~/supernote ~/sndata
```

Meine Compose-Datei sieht jetzt so aus:

{{< collapse "compose.yml" >}}

```yml
services:
  mariadb:
    image: mariadb:10.6.24
    container_name: mariadb
    networks:
      - supernote-net
    environment:
      MYSQL_ROOT_PASSWORD: "changeMe"
      MYSQL_DATABASE: supernotedb
      MYSQL_USER: "supernote_user"
      MYSQL_PASSWORD: "changeMe"
    volumes:
      - mariadb_data:/var/lib/mysql
      - ./supernotedb.sql:/docker-entrypoint-initdb.d/supernotedb.sql:ro
    restart: unless-stopped

  redis:
    image: redis:7.4.7
    container_name: redis_supernote
    networks:
      - supernote-net
    volumes:
      - redis_data:/data
    command: redis-server --requirepass 'changeMe2' --dir /data --dbfilename dump.rdb
    restart: unless-stopped

  notelib:
    image: docker.io/supernote/notelib:6.9.3
    container_name: notelib
    networks:
      - supernote-net
    restart: unless-stopped

  supernote-service:
    image: docker.io/supernote/supernote-service:25.11.24
    container_name: supernote-service
    networks:
      - supernote-net
    ports:
      - "127.0.0.1:18072:18072"
      - "127.0.0.1:19072:8080"
    volumes:
      - ~/sndata/recycle:/home/supernote/recycle
      - ~/supernote:/home/supernote/data
      - ~/sndata/logs/cloud:/home/supernote/cloud/logs
      - ~/sndata/logs/app:/home/supernote/logs
      - ~/sndata/logs/web:/var/log/nginx
      - ~/sndata/convert:/home/supernote/convert
      - /etc/localtime:/etc/localtime:ro
    environment:
      MYSQL_DATABASE: supernotedb
      MYSQL_USER: "supernote_user"
      MYSQL_PASSWORD: "changeMe"
      REDIS_HOST: redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: "changeMe2"
    depends_on:
      - mariadb
      - redis
      - notelib
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  supernote-net:
    name: supernote-net

volumes:
  mariadb_data:
  redis_data:
```

{{< /collapse >}}

## Nginx (Reverse Proxy)

Supernote hat einen [Konfigurationsausschnitt](https://support.supernote.com/Whats-New/setting-up-your-own-supernote-private-cloud-beta) für Nginx als Reverse Proxy zur Handhabung der HTTPS-Terminierung bereitgestellt, was genau das ist, was ich tue 😊. Ich habe nur `YOUR_PRIVATE_CLOUD_IP_ADDRESS` durch `127.0.0.1` ersetzt und die SSL-Einstellungen entfernt, da diese von [Certbot](https://certbot.eff.org/) verwaltet werden.

{{< collapse "nginx-Konfigurationsausschnitt" >}}

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
server {
        server_name  example.com;
        client_max_body_size 20480m;
        access_log /var/log/nginx/sn.access.log;
        error_log /var/log/nginx/sn.error.log;
    location / {
            proxy_pass http://127.0.0.1:19072;
            proxy_set_header Host $proxy_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_redirect http:///127.0.0.1:19072/ https://$host/;
            proxy_redirect https:///127.0.0.1:19072/ https://$host/;
            proxy_redirect ~*^https?://[^/]+:19072(/?.*)$ https://$host$1;

            sub_filter_once off;
            sub_filter_types *;
            sub_filter 'http:///127.0.0.1:19072' 'https://$host';
            sub_filter 'https:///127.0.0.1:19072' 'https://$host';
            sub_filter ':19072' '';

            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;

            proxy_connect_timeout 6000;
            proxy_send_timeout 6000;
            proxy_read_timeout 6000;
     }
    location ~ ^/socket.io/(.*) {
            proxy_ignore_client_abort on;
            proxy_http_version 1.1;
            proxy_connect_timeout 60s;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
            proxy_set_header   X-NginX-Proxy    true;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "$connection_upgrade";
            proxy_pass http://127.0.0.1:18072;
            proxy_redirect off;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

{{< /collapse >}}

## Login

Beim Öffnen der Private-Cloud-Seite wurde ich mit einer Login-/Registrierungsseite begrüßt. Für die Registrierung musste ich Mail-Einstellungen konfigurieren. Obwohl die Test-Mail von meinem primären Mail-Anbieter [mailbox.org](https://mailbox.org/en/) gesendet und empfangen wurde, erhielt ich die Registrierungs-Mail für meine eigentliche Registrierung nicht. Erst als ich mein Backup-Gmail-Konto konfigurierte, wurde meine Registrierungs-Mail erfolgreich zugestellt und ich konnte ein Konto erstellen.

## Synchronisation

Nach dem Ausloggen aus meinem Supernote-Konto aktivierte ich die Private Cloud in den Einstellungen und meldete mich mit meinem Konto an. Die ~manuelle~ Synchronisation meines Supernote mit meiner privaten Cloud funktionierte einwandfrei. ~Die automatische Synchronisation erfordert Port 18072, der derzeit nicht für das Web auf meinem Server exponiert ist. Das Supernote-Team arbeitet an einer Lösung, den automatischen Synchronisations-Port sicher über HTTPS bereitzustellen[^1].~

> [!INFO]
> Mit der neuesten Version [25.12.17](https://support.supernote.com/change-log/supernote-private-cloud-changelog/version/8) hat Supernote „Auto-Sync über HTTPS in Reverse-Proxy-Umgebungen" eingeführt 🥳 Ich habe den Nginx-Ausschnitt oben entsprechend aktualisiert.

[^1]: [reddit.com](https://www.reddit.com/r/Supernote/comments/1ox8uox/comment/nquep5o/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)
