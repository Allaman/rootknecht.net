---
title: Proxy a database via SSH
summary: A brief demonstration of how to connect to a PostgreSQL database via SSH, implemented using Docker Compose.
description: database, cloud, networking, linux, ssh
date: 2025-01-20
tags:
  - devops
  - docker
  - configuration
---

## Why?

As a workaround for accessing databases for troubleshooting purposes, such as managed databases in AWS, Azure, etc., adopt an SSH proxy suited to your environment.
For example, use a minimal virtual machine within the same network as your database but with a public network interface.

## Just gimme the code

```yaml
---
services:
  # Note the missing `ports` key. Postgres does not open a Port on the host.
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: db
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  ssh-proxy:
    image: debian
    # Install and configure SSH Daemon
    command: >
      bash -c "apt-get update &&
              apt-get install -y openssh-server &&
              mkdir /run/sshd &&
              echo 'root:test' | chpasswd &&
              sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config &&
              sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config &&
              sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config &&
              /usr/sbin/sshd -D"
    ports:
      - "443:22"
    networks:
      - backend
    depends_on:
      postgres:
        condition: service_healthy

networks:
  backend:
    driver: bridge
```

In this example, we configured port 443 for our SSH proxy (instead of the usual port 22).
This can be useful in environments that allow only HTTP(s) ports."

Start the demo

```sh
docker compose up [-d]
```

Open the forwarding on your local machine.[^1]:

```sh
ssh -p 443 root@localhost -L 5432:postgres:5432
```

Enter `test` as password[^2].

Just check if a TCP connection can be established (if you don't have a psql client available 😄).

```sh
nc -zv localhost 5432 # netcat
```

Connect to the database as usual.

```sh
psql -h localhost -U postgres -d db
```

Use `postgres` as password.

## The "magic"

For me, it felt like magic when I first heard about `-L` from my senior colleague back in the day.

From `man ssh`:

> Specifies that connections to the given TCP port or Unix socket on the local (client) host are to be forwarded to the given host and port, or Unix socket, on the remote side.

In other words `5432:postgres:5432` says that my local port `5432` should be forwarded to the host `postgres` on port `5432`, which corresponds to the database container.

## Considerations

- Keep potential security implications and compliance requirements in mind. Although your database remains technically internal, you are still opening a door.
- Consider starting the proxy only when needed.
- Consider using SSH keys instead of password authentication.
- Consider leveraging dedicated services from your cloud provider, such as (managed) bastions or VPNs, for this scenario.

[^1]: Some IDEs offer a SSH Proxy setting so you don't need this step.

[^2]: The session needs to be opened as long as you work with the database.
