---
title: SSL/TLS/HTTPS
summary: How to handle certificates and related stuff
---

## Generate self-signed certificate for https

**Simple usecase**

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -keyout key.pem -out cert.pem -days 365
```

**Advanced usecase**
Including *S*ubject *A*lternative *N*ames

```bash
openssl req \
-newkey rsa:4096 \
-x509 \
-nodes \
-keyout key.pem \
-out cert.pem \
-subj "/C=DE/ST=Munich/L=Bavaria/O=department/OU=company/CN=example.com" \
-reqexts SAN \
-extensions SAN \
-config <(cat /etc/ssl/openssl.cnf \
    <(printf '[SAN]\nsubjectAltName=IP:127.0.0.1,DNS:localhost')) \
-sha256 \
-days 365
```

{{< alert >}}
Path of `/etc/ssl/openssl.cnf` might differ
{{< /alert >}}

## Remove password from protected certificate key

```bash
openssl rsa -in original.key -out unencripted.key
```

## Lets encrpyt certificate

Instead of cert.pem use fullchain.pem to prevent "missing local issuer" error

## Check a private key

```bash
openssl rsa -in priv.key -check
```

## Check a certificate

```bash
openssl x509 -in cert.pem -text -noout
```

## Check a pksc12 certificate

```bash
openssl pkcs12 -info -in keyStore.p12
```

## Convert a pksc12 certificate to pem

```bash
openssl pkcs12 -in keyStore.[pfx|p12] -out keyStore.pem -nodes
```

`-nocerts` to only output the private key or `-nokeys` to only output the certificates.

## Create a pksc12|pfx file

```sh
openssl pkcs12 -export -out example.com.pfx -inkey example.com.key -in example.com.pem -certfile foo_intermediate.pem -certfile bar_intermediate.pem -certfile super_ca_root.pem
```

## Compare key and certificate

When the key matches the certificate only one has output is returned

```sh
(openssl rsa -noout -modulus -in example.com.key | openssl md5; openssl x509 -noout -modulus -in example.com.pem | openssl md5) | uniq
```

## Get SSL/TLS certificate information

```bash
alias get-ssl-cert='echo Q |openssl s_client -connect' # prints certificate
alias get-ssl-fingerprint='openssl x509 -in cert.pem -sha1 -noout -fingerprint'
```

Example:

```bash
get-ssl-cert google.com:443 > cert.pem
get-ssl-fingerprint # assumes cert.pem in current directory
```

## Emulate SSL/TLS Handshake

```bash
openssl s_client -state -nbio -connect HOST:PORT
```

## Get a certificate from remote

```bash
curl --insecure -v https://google.com 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
```

## Get end date of a certificate

```sh
openssl x509 -enddate -noout -in <CERT>
```

## Mutual SSL connection with nginx

Generating CA, certificates, and keys

```bash
# Generate CA and CA key to sign CSRs
# -des3 for password protection of the CA key
openssl genrsa -des3 -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt

# Generate Server key and CSR
# Optionally use -des3 for password protection of the server key
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr

# Sign the server CSR with the CA key
# Enter the pass provided in the first step
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

# Generate Client key and CSR
# Optionally use -des3 for password protection of the client key
openssl genrsa -out client.key 4096
openssl req -new -key client.key -out client.csr

# Singn the client CSR with the CA key
# Enter the pass provided in the first step
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt

# Optionally create a PKCS 12 archive for importing client certificate data in web browsers
openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12
```

Relevant snippet for nginx.conf

```ini
listen *:443;               # Listen for incoming connections from any interface on port 443 (TLS)
ssl on;
ssl_certificate        /etc/nginx/certs/server.crt;
ssl_certificate_key    /etc/nginx/certs/server.key;
ssl_client_certificate /etc/nginx/certs/ca.crt; # used to sign the client certificates
ssl_verify_client      on; # force SSL verification
```

Testing with curl (assuming nginx is running on localhost listening to standard https port)

```bash
curl --insecure https://localhost
# --insecure as we use self signed certificates
```

```html
<center><h1>400 Bad Request</h1></center>
<center>No required SSL certificate was sent</center>
```

```bash
curl --insecure --key client.key --cert client.crt  https://localhost
```

```html
<h1>Welcome</h1>
<p>This is my home page</p>
```
