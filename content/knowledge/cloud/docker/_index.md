---
title: Docker
---

{{< toc >}}

## Docker CLI

{{< hint info >}}
See [Full CLI reference](https://docs.docker.com/engine/reference/commandline/docker/#child-commands) for a comprehensive documentation
{{< /hint >}}

### Getting information

| Command           | Result                                |
| ----------------- | ------------------------------------- |
| docker version    | Get version info about docker         |
| docker info       | Get overview of different docker info |
| docker ps         | List running containers               |
| docker ps -a      | List all existing containers          |
| docker system df  | Get storage usage of Docker           |
| docker system top | Get running process of a container    |
| docker stats      | List live stream of container usage   |

### Managing volumes

| Command                           | Result                           |
| --------------------------------- | -------------------------------- |
| docker volume ls                  | List all docker volumes          |
| docker volume inspect _VOLUME-ID_ | List detailed volume information |

### Managing images

| Command               | Result                 |
| --------------------- | ---------------------- |
| docker image ls       | List local images      |
| docker rmi _IMAGE-ID_ | Remove specified image |
| docker image prune    | Remove unused images   |
| docker image prune -a | Remove all images      |

### Managing container

| Command                                   | Result                            |
| ----------------------------------------- | --------------------------------- |
| docker exec -it _CONTAINER-ID_ [bash\|sh] | Log into the container            |
| docker exec _CONTAINER-ID_ _command_      | Executes command in the container |

### Clean up

| Command                         | Result                       |
| ------------------------------- | ---------------------------- |
| docker stop $(docker ps)        | Stops all running containers |
| docker rm $(docker ps -q)       | Removes all containers       |
| docker rm $(docker image ls -q) | Deletes all images           |

Alternative for Docker API 1.25 and greater:

| Command                | Result                                           |
| ---------------------- | ------------------------------------------------ |
| docker system prune    | Removes unused data                              |
| docker system prune -a | Removes unused data but not just dangling images |

## Prevent a container from exiting

After starting a service via docker-compose Docker will shut it down if there is no process running. To prevent that you can call a "dummy" endless command - in this case by overriding the entrypoint with a simple ping.

```yaml
entrypoint: ping localhost
```

## Run a command in the docker namespace

```sh
sudo nsenter -t $(docker inspect -f '{{.State.Pid}}' <CONTAINER_NAME_OR_ID>) -n <CMD>
```

For instance to run netstat and show connections of the container.

## Show file usage of Docker on a btrfs partition

The btrfs storage driver of Docker is kind of different. A normal `df -hkl /var/lib/docker` will not show correct numbers. Instead use the tools of btrfs:

```bash
btrfs fi df /varLib/docker
```

## Docker and Proxy

### System

vim /etc/systemd/system/multi-user.target.wants/docker.service (adjust for other startup mechanism)

```
[Service]
Environment="HTTPS_PROXY=https://proxy.example.com:443/"
```

### Per build

```bash
docker build --build-arg HTTP_PROXY=proxy.company.com:3128 -t TAG .
```

## Exec a command without entering a container

```bash
docker exec CONTAINER sh -c "cat /tmp/test"
```

## Fast Testing with alpine and docker-compose

```bash
version: "3.0"
services:
  alpine:
    image: alpine
    volumes:
      - /tmp/:/tmp/
    tty: true
```

Starting the service with `docker-compose up -d`keeps the container running

## Tag and push

`registry.port/` is optional when pushing to duckerhub

```sh
docker login
docker build . -t foobar
docker tag foobar registry:port/name/foobar
docker push foobar registry:port/name/foobar
```

## Set docker host

```bash
DOCKER_HOST=tcp://192.168.56.101:2375
# with TLS enabled Daemon
# make sure that ~/.docker/ of the current user contains the ca.pem or the {cert,key}.pem in case of client auth
export DOCKER_TLS_VERIFY=1
```

## Check container config for initial start

Set the timestamp of your configuration in the `Dockerfile` file to zero

```
RUN         touch -d @0 /config.yml
```

In your entrypoint check the timestamp. When the timestamp is zero the container is started for the first time

```bash
if [ "$(stat --format %Y /config.yml)" -eq 0 ]; then
# initial start of the container
fi
```

## Autostart a container with systemd

/etc/systemd/system/NAME.service

```
[Unit]
Description=Start Container
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a CONTAINER
ExecStop=/usr/bin/docker stop -t 5 CONTAINER

[Install]
WantedBy=multi-user.target
```

Start und enable service at boot time

```bash
systemctl start NAME
systemctl enable NAME
```

## Inspect a restarting container

```bash
docker commit CONTAINERID test
docker run -it --entrypoint=/bin/bash test
```

## Mount Docker socket on Windows

Pay attention to double slash

```sh
-v //var/run/docker.sock:/var/run/docker.sock
```
