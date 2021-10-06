---
title: Gitlab
---

{{< toc >}}

## Gitlab CE Docker and external Nginx Reverse Proxy

Gitlab provides official [Docker images](https://docs.gitlab.com/omnibus/docker/). The following config shows the integration in nginx of an out of the box gitlab container with docker-compose.yml.

## docker-compose

```yml
version "2"
services:
    gitlab:
      image: 'gitlab/gitlab-ce:latest'
      restart: always
      ports:
        - '80:80'
        - '443:443'
        - '22:22'
      volumes:
        - '/srv/gitlab/config:/etc/gitlab'
        - '/srv/gitlab/logs:/var/log/gitlab'
        - '/srv/gitlab/data:/var/opt/gitlab'
```

## Gitlab

In `/etc/gitlab/gitlab.rb` (from within the container) or in `/srv/gitlab/config/gitlab.rb` from within the host:

```ruby
external_url 'https://domain.tld/gitlab/'

nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['proxy_set_headers'] = {
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
}

```

After changing the config reconfigure gitlab:

```bash
# open a bash in the gitlab container
docker exec -it gitlab bash
# reconfigure gitlab
gitlab-ctl reconfigure
```

## Nginx Settings

```nginx
server {
    listen 443 ssl;
    server_name domain.tld;
    index index.html index.htm;
    error_log /var/log/nginx/error.log error;
    location /gitlab {
        client_max_body_size 0;
        gzip off;
        proxy_read_timeout      300;
        proxy_connect_timeout   300;
        proxy_redirect          off;
        proxy_http_version 1.1;
        proxy_set_header    Host                $http_host;
        proxy_set_header    X-Real-IP           $remote_addr;
        proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto   $scheme;
        proxy_pass http://<gitlab>:80;
    }
    ssl_certificate /etc/nginx/cert.pem;
    ssl_certificate_key /etc/nginx/cert.key;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # intermediate configuration. tweak to your needs.
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    # ssl_ciphers ALL:!aNULL:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
    ssl_prefer_server_ciphers on;

    # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
    add_header Strict-Transport-Security max-age=15768000;

    # OCSP Stapling ---
    # fetch OCSP records from URL in ssl_certificate and cache them
    ssl_stapling on;
    ssl_stapling_verify on;
}

```

Reload nginx:

```bash
# check config syntx
nginx -t
# reload
nginx -s reload
```

## CI/CD

### Install gitlab-runner

```bash
docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest
```

More install options are [available](https://docs.gitlab.com/runner/install/)

### Register gitlab-runner

Run in your runner host (here in the docker container)

```
sudo gitlab-runner register
```

- Get your token from `/admin/runners` of your Gitlab instance
- Set your [executioner](https://docs.gitlab.com/runner/executors/README.html) (here docker)
- No tags, allow untagged jobs, no shared runner (without those settings the runner stuck)

### Basic maven build

add and push `.gitlab-ci.yml` in your project root

```yml
image: maven:latest

verify:
  stage: build
  script:
    - mvn verify

build:
  stage: build
  script:
    - mvn compile
```

### Gitlab Pages

Recommended: wildcard domain and corresponding SSL certificate

1. Assign a runner to a group of projects in Gitlab [runner](https://docs.gitlab.com/ee/ci/runners/)
1. Start runner `docker run -d --name gitlab-runner-public --restart always -v /srv/gitlab-runner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest`
1. [Register runner](https://docs.gitlab.com/runner/register/index.html)
   The docker image used can be overwritten in the .gitlab-ci.yml of your pipeline
   1. interactive: `docker exec -it gitlab-runner-public bash`
      - gitlab-runner register
      - docker as default executioner
      - alpine as default image
   1. or non interactive
      ```bash
      docker run --rm -t -i -v /path/to/config:/etc/gitlab-runner --name gitlab-runner gitlab/gitlab-runner register \
      					--non-interactive \
      					--executor "docker" \
                        	--docker-image alpine:3 \
                        	--url "https://gitlab.com/" \
                        	--registration-token "PROJECT_REGISTRATION_TOKEN" \
                        	--description "docker-runner" \
                        	--tag-list "docker,aws" \
                        	--run-untagged \
                        	--locked="false"
      ```

````

1. Setup [Pages](https://gitlab.com/pages) (wildcard domain with TLS support)
	gitlab.rb
  ```ruby
          pages_external_url "https://pages.rootknecht.net/"
          gitlab_pages['enable'] = true
          gitlab_pages['inplace_chroot'] = true # in case of gitlab-pages daemon not starting due to bind mount permission error
          pages_nginx['redirect_http_to_https'] = true
          pages_nginx['ssl_certificate'] = "/etc/gitlab/ssl/pages-nginx.crt"
          pages_nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/pages-nginx.key"
  ```
	Reconfigure and restart
  ```bash
      gitlab-ctl reconfigure
      gitlab-ctl restart gitlab-pages
  ```
  Debugging
  ```bash
  	# get logs (run in container)
		gitlab-ctl tail gitlab-pages
      # path of your pages (in container)
      ls /var/opt/gitlab/gitlab-rails/shared/pages
      # error log of bundled nginx
      /var/log/gitlab/nginx/gitlab_pages_error.log
	```

### Basic Pages Pipeline
Publish static html content with following `.gitlab-ci.yml`
```yaml
image: alpine:latest
pages:
stage: deploy
script:
- echo 'Nothing to do...'
artifacts:
  paths:
  - public # this is the path in your repo to publish
only:
- master

````

## LDAP and Mail integration

In `gitlab.rb`

```ruby
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "<SMTP Host>"
gitlab_rails['smtp_port'] = "587"
gitlab_rails['smtp_user_name'] = "<user>"
gitlab_rails['smtp_password'] = "<password>"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_openssl_verify_mode'] = 'none' # change if there are valid certificates
gitlab_rails['gitlab_email_from'] = "<MAIL FROM>"
gitlab_rails['gitlab_email_reply_to'] = "<REPLY TO>"

gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = {
'main' => {
  'label' => 'Description',
  'host' =>  '<LDAP-HOST',
  'port' => 389, # 636 for secured connection
  'uid' => 'sAMAccountName',
  'verify_certificates' => true,
  'bind_dn' => '<can be full bind or username>',
  'password' => '<password>',
  'method' => 'plain', # change for enrypted connections
  'base' => '<BASE DN>',
  'active_directory' => true, # true only for Microsoft AD
  'allow_username_or_email_login' => true,
  'user_filter' => '(&(objectCategory=Person)(sAMAccountName=*))'
  }
}
```

## Deploy Gitlab with Docker on NixOS

### Install docker service

Add `virtualisation.docker.enable = true;` and optionally `extraGroups= [ "docker" ]` to a user who needs to control docker to your configuration.nix file.

### Install docker-compose

Add `python36Packages.docker_compose` to `environment.systemPackages`

### Open firewall ports

`networking.firewall.allowedTCPPorts = [ 80 443 ]`

### Create docker-compose.yml

{{< hint info >}}
Adjust paths and ports according to your setup
{{< /hint >}}

```docker
version: '2'

services:
  web:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: 'gitlab'
    ports:
      - '80:80'
      - '443:443'
      - '50222:22'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
```

Run `docker-compose up -d` to start the service in the backgroud. You should now be able to access gitlab with your machine's IP

### Install openssl and generate certificates

Add `openssl` to `environment.systemPackages`
`openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365`

{{< hint info >}}
Alternative: Use lets encrypt
{{ /hint >}}

### Gitlab configuration

The main configuration file is `/srv/gitlab/config/gitlab.rb` (adjust your path according to your docker-compose file)

### Enable https

In gitlab.rb put 'external_url "https://gitlab.example.com"'. Gitlab will look after your certificates according to your hostname - here `/etc/gitlab/ssl/gitlab.example.com.key` and `/etc/gitlab/ssl/gitlab.example.com.crt`.
{{< hint info >}}
Note that this is the path inside of the container and won't be permanent - on your docker host the correct path is `/srv/gitlab/config/ssl/`
{{< /hint >}}
Create the ssl directory and copy your previously generated files `cert.pem` and `cert.key` to this folder and rename them. The cert.pem file is the .crt file and the key.pem the .key file.

Now connect to your container with `docker exec -it gitlab_web_1` and run `gitlab-ctl reconfigure` inside your container.

### Redirect http

After enabling https gitlab does not listen to http anymore. To redirect incoming http traffic to https put `nginx['redirect_http_to_https'] = true` in your gitlab.rb file.
