---
title: Java
---

My notes on Java

{{< toc >}}

## Java key store vs trust store

1. trustStore is used by `TrustManager` class and keyStore is used by `KeyManager` class
1. `TrustManager` determines whether remote connection should be trusted or not; `KeyManager` decides which authentication credentials should be sent to the remote host for authentication during SSL handshake
1. `KeyStore` contains private keys and is required only if you are running a Server in SSL connection or you have enabled client authentication on server side. TrustStore stores public key or certificates from CAs which tells Java to trust a remote party or SSL connection
1. Default: `$JAVA_HOME/jre/lib/security/cacerts`

## Create java trust store

```bash
# Import CA and create new trustStore
keytool -import -trustcacerts -storepass changeit -file /PATH/TO/FIRSTCA.cert -alias firstCA -keystore /PATH/TO/TRUSTSTORE
```

## Use Java key / trust store

{{< hint info >}}
Will override the default stores
{{< /hint >}}

```bash
-Djavax.net.ssl.trustStore=/PATH/TO/TRUSTSTORE
-Djavax.net.ssl.trustStorePassword=PASSWORD
-Djavax.net.ssl.keyStore=/PATH/TO/KEYSTORE
-Djavax.net.ssl.keyStorePassword=PASSWORD
```

## Keytool commands

List certificates

```bash
keytool -list -v -keystore /PATH/TO/STORE
```

Change password of keystore

```bash
keytool -storepasswd -new new_storepass -keystore /PATH/TO/KEYSTORE
```

Import CA

```bash
# repeat for each certificate
keytool -import -file /PATH/TO/FIRSTCA.cert -alias firstCA -keystore /PATH/TO/TRUSTSTORE
```

## Check HTTPS connection with Java

```java
// SSLPoke.java
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import java.io.*;

public class SSLPoke {
    public static void main(String[] args) {
        if (args.length != 2) {
            System.out.println("Usage: "+SSLPoke.class.getName()+" <host> <port>");
            System.exit(1);
        }
        try {
            SSLSocketFactory sslsocketfactory = (SSLSocketFactory) SSLSocketFactory.getDefault();
            SSLSocket sslsocket = (SSLSocket) sslsocketfactory.createSocket(args[0], Integer.parseInt(args[1]));

            InputStream in = sslsocket.getInputStream();
            OutputStream out = sslsocket.getOutputStream();

            // Write a test byte to get a reaction :)
            out.write(1);

            while (in.available() > 0) {
                System.out.print(in.read());
            }
            System.out.println("Successfully connected");

        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }
}
```

```bash
javac SSLPoke.java
java SSLPoke HOST PORT
# Test your Truststore
java -Djavax.net.ssl.trustStore=/PATH/TO/TRUSTSTORE -Djavax.net.ssl.trustStorePassword=PASSWORD SSLPoke HOST PORT
```

Adopted from https://gist.github.com/4ndrej/4547029

## Get SSL ciphers available on JVM

```java
// Ciphers.java
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;
import javax.net.ssl.SSLServerSocketFactory;

public class Ciphers
{
    public static void main(String[] args)
        throws Exception
    {
        SSLServerSocketFactory ssf = (SSLServerSocketFactory)SSLServerSocketFactory.getDefault();

        String[] defaultCiphers = ssf.getDefaultCipherSuites();
        String[] availableCiphers = ssf.getSupportedCipherSuites();

        TreeMap ciphers = new TreeMap();

        for(int i=0; i<availableCiphers.length; ++i )
            ciphers.put(availableCiphers[i], Boolean.FALSE);

        for(int i=0; i<defaultCiphers.length; ++i )
            ciphers.put(defaultCiphers[i], Boolean.TRUE);

        System.out.println("Default\tCipher");
        for(Iterator i = ciphers.entrySet().iterator(); i.hasNext(); ) {
            Map.Entry cipher=(Map.Entry)i.next();

            if(Boolean.TRUE.equals(cipher.getValue()))
                System.out.print('*');
            else
                System.out.print(' ');

            System.out.print('\t');
            System.out.println(cipher.getKey());
        }
    }
}
```

```bash
javac Ciphers.java
java Ciphers
```

## Test SSL ciphers offered by remote server

```bash
#!/usr/bin/env bash

# OpenSSL requires the port number.
SERVER=$1
DELAY=1
ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')

echo Obtaining cipher list from $(openssl version).

for cipher in ${ciphers[@]}
do
echo -n Testing $cipher...
result=$(echo -n | openssl s_client -cipher "$cipher" -connect $SERVER 2>&1)
if [[ "$result" =~ ":error:" ]] ; then
  error=$(echo -n $result | cut -d':' -f6)
  echo NO \($error\)
else
  if [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    :" ]] ; then
    echo YES
  else
    echo UNKNOWN RESPONSE
    echo $result
  fi
fi
sleep $DELAY
done
```

## Spring Boot + Maven + Docker

Add to your `pom.xml`

```xml
            <plugin>
                <groupId>com.spotify</groupId>
                <artifactId>dockerfile-maven-plugin</artifactId>
                <version>1.4.0</version>
                <configuration>
                    <repository>IMAGENAME</repository>
                    <forceCreation>true</forceCreation>
                    <buildArgs>
                        <JAR_FILE>target/${project.build.finalName}.jar</JAR_FILE>
                    </buildArgs>
                </configuration>
</plugin>
```

Dockerfile

```yml
FROM openjdk:8

ARG JAR_FILE
ADD ${JAR_FILE} /app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app.jar"]
```

Build with `mvn dockerfile:build`

## Check SIGTERM vs SIGKILL

```java
public class Test {
    public static void main(String[] args) {
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                System.out.println("Shutdown Hook executed!");
            }
        });
        for (int i=0; i<100000; i++) {
            System.out.println("Wating....");
            try {
                Thread.sleep(5000);
            } catch (InterruptedException e) {
                System.err.println(e);
            }
         }
    }
}
```

```bash
kill PID     # Hook will be executed
kill -9 PID # Hook will not be executed
```

## Access system clipboard

```java
public static String readClipboard(){
    return (String) Toolkit.getDefaultToolkit().getSystemClipboard().getData(DataFlavor.stringFlavor);
}
```

## List supported signals

```bash
#!/bin/bash

# Get temp dir
tmpdir="./tmp"

# Generate test
test -e ${tmpdir} || mkdir ${tmpdir}
cat > ${tmpdir}/ListenToSignal.java <<EOF
import sun.misc.Signal;
import sun.misc.SignalHandler;
public class ListenToSignal {
    public static void main(String[] args) {
        try {
            Signal.handle(new Signal(args[0]), new SignalHandler() {
                public void handle(Signal sig) {
                    System.out.println(sig.getName() + ": yes");
                    System.exit(0);
                }
            });
            Thread.sleep(5000L);
            System.out.println(args[0] + ": no");
        } catch (Throwable t) {
            System.out.println(args[0] + ": no (" + t.getMessage() + ")");
        }
        System.exit(1);
    }
}
EOF

# Compile test
javac ${tmpdir}/ListenToSignal.java &>/dev/null

# Get signals, test each one of them
for signal in $(kill -l); do
  java -cp ${tmpdir} ListenToSignal $signal &  	 # Start program in background
  sleep 2                                      								# Make sure it is ready
  kill -s $signal $! &>/dev/null               					# Send signal
  wait                                         									# Wait to termination
done
```

## Maven

**Skip tests**

```sh
-DskipTests=true -Dmaven.test.skip=true
```

## Compile and run from CLI

```sh
javac [-cp classpath1.jar:classpath2.jar:.] CLASSNAME.java
java [-cp classpath1.jar:classpath2.jar:.] CLASSNAME
```

## Create a jar form command line

```sh
jar cfe NAME.jar ENTRYPOINTCLASSNAME *.class
```
