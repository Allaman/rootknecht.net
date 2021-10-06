---
title: Drone
---

{{< toc >}}

## Use Drone to scp files to a target

With [Drone-scp](http://plugins.drone.io/appleboy/drone-scp/)

Add secrets (use exact these names)

```bash
./drone secret add --repository REPO -name SSH_PASSWORD -value PASSWORD
./drone secret add --repository REPO -name SSH_KEY -value @/path/to/id_rsa
./drone secret add --repository REPO -name SSH_USERNAME -value USER
```

.drone.yml

```yaml
pipeline:
  deploy:
    image: appleboy/drone-scp
    host: HOST
    port: 22
    secrets: [SSH_USERNAME, SSH_PASSWORD]
    # secrets: [ SSH_USERNAME, SSH_KEY ]
    rm: true
    source:
      - src/
    target:
      - /var/www/html
    strip_components: 1
```

## Use Drone to ssh on remote hosts and execute commands

```yaml
pipeline:
  ssh:
    image: appleboy/drone-ssh
    host: HOST
    port: 22
    secrets: [SSH_USERNAME, SSH_PASSWORD]
    script:
      - echo "Hello World"
      - ps aux
```

## Get notified by drone build

Username and password must be provided

```yaml
pipeline
  notify:
    image:     drillster/drone-email
    from:        drone@example.com
    host:        smtp.example.com
    skip_verify: true
    secrets:     [ email_username, email_password ]
    subject:     >
        [DRONE CI]: {{ build.status }}: {{ repo.owner }}/{{ repo.name }}
        ({{ commit.branch }} - {{ truncate commit.sha 8 }})
    recipients:
        - allaman@rootknecht.net
```
