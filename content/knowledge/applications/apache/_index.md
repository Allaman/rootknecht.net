---
title: Apache
---

{{< toc >}}

## Simple rewrite http to https

```ini
RewriteEngine On
RewriteRule ^/app1(.*)$ https://example.com/app1$1 [R,L]
RewriteRule ^/app2(.*)$ https://example.com/app2$1 [R,L]
```

## Basic authentication

```bash
sudo htpasswd -c /etc/apache2/htpasswd user1
sudo htpasswd /etc/apache2/htpasswd user2 # no -c when file exists
```

/etc/apache2/apache2.conf

```ini
<Directory "/var/www/html">
    AuthType Basic
    AuthName "NO ACCESS"
    AuthUserFile /etc/apache2/htpasswd
    Require valid-user
</Directory>
```

/var/www/html/.htaccess

```ini
AuthType Basic
AuthName "NO ACCESS"
AuthUserFile /etc/apache2/htpasswd
Require valid-user
```

## Send custom headers as reverse proxy

Some applications require to receive custom headers in order to work, e.g. Syncthing expects a X-API-KEY header in a request.

```apache
<VirtualHost *:443>
        Header add HEADER "VALUE"
        RequestHeader set HEADER "VALUE"
</VirtualHost>
```

## Enable browser cache

with **mod_expires**

```bash
a2enmod expires
systemctl restart apache2
```

.htaccess or in your virtual host

```ini
 <IfModule mod_expires.c>
   ExpiresActive On
   ExpiresByType application/vnd.ms-fontobject "access plus 1 year"
   ExpiresByType application/x-font-ttf "access plus 1 year"
   ExpiresByType application/x-font-opentype "access plus 1 year"
   ExpiresByType application/x-font-woff "access plus 1 year"
   ExpiresByType image/svg+xml "access plus 1 year"
   ExpiresDefault "access plus 2 days"
   ExpiresByType text/html "access plus 2 days"
   ExpiresByType image/gif "access plus 3 months"
   ExpiresByType image/jpeg "access plus 3 months"
   ExpiresByType image/jpg "access plus 3 months"
   ExpiresByType image/png "access plus 3 months"
   ExpiresByType image/x-png "access plus 3 months"
   ExpiresByType text/css "access plus 8 days"
   ExpiresByType text/javascript "access plus 7 days"
   ExpiresByType application/x-javascript "access plus 7 days"
   ExpiresByType application/javascript "access plus 7 days"
   ExpiresByType image/x-icon "access plus 3 months"
 </IfModule>
```

or with **mod_headers**

```bash
a2enmod headers
systemctl restart apache2
```

.htaccess (or apache.conf)

```ini
<IfModule mod_headers.c>
<FilesMatch "\.(gif|ico|jpeg|jpe|png|css|js)$">
Header set Cache-Control "max-age=604800, public"
</FilesMatch>
</IfModule>
```

## Enable FPM/FastCGI

- Install `php7.x-fpm`
- Activate mods

```sh
a2enmod actions fastcgi alias proxy_fcgi
a2enconf php7.x-fpm
```

- check status of fpm service

```sh
systemctl status php7.3-fpm
```

- Add to your apache config:

```
<FilesMatch \.php$>
  <If "-f %{SCRIPT_FILENAME}">
    SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost"
  </If>
</FilesMatch>
```

- Test

```
echo "<?php phpinfo(); ?>" > /var/www/test/index.php
```

## SVN + Auth

Setup SVN accessible through Apache with local + ldap authentication and user based authorization

### Create svn repo

```bash
svnadmin create path/to/repo
chown -R www-data:www-data path/to/repo # adjust apache user if needed
# optionally dump and import existing repo
svnadmin dump file:///path/to/exisitngt > repo.dump
svnadmin load /path/to/repo < repo.dump
```

### Setup Apache

Install/enable `mod_dav_svn`, `mod_authz_svn`, and `mod_authnz_ldap`

Add location to your `apache.conf`:

```ini
 <Location /repo>
        Options                    Includes Indexes FollowSymLinks ExecCGI
        AllowOverride              None
        Order                      allow,deny
        Allow                      from all
        AuthType                   basic
        AuthName                   "SVN Repo Auth"
        AuthzSVNAccessFile         /path/to/authz
        require                    valid-user
        DAV                        svn
        SVNPath                    /path/to/repo
        SVNReposName               "SVN Repo"
        SVNAllowBulkUpdates        on
        SVNCacheRevProps           on

        AuthBasicAuthoritative     off
        AuthBasicProvider          ldap file # provide multiple auth provider
        AuthUserFile               /path/to/passwd
        AuthzLDAPAuthoritative     off
        AuthLDAPDereferenceAliases never
        AuthLDAPBindDN             "CN=svn_user,OU=svn,DC=example,DC=com"
        AuthLDAPBindPassword       "password"
        AuthLDAPURL                "ldap://ldap.example.com/OU=svn users,DC=example,DC=com?sAMAccountName?sub?(&(objectClass=user))"
    </Location>
```

### Setup local users

```bash
htpasswd -c /path/to/passwd USER
```

### Setup authorization

Edit ` /path/to/authz` according to the following scheme:

```ini
[aliases]
TMU     = muellet
MHU     = hummelm
MGO     = gomezm

[groups]
ADM     = &TMU,&MHU
MGO     = &MGO

[/]
@ADM    = rw
*       = r

[/all.md]
@FK     = rw
@ADM    = rw
*       =

[/ADM]
@ADM    = rw
*       =
[/MGO]
@ADM    = rw
@MGO    = rw
*       =
```
