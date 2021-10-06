---
title: Jenkins
---

{{< toc >}}

## Reverse proxy config

{{< hint warning >}}
Adjust jenkins prefix accordingly depending on your install method, e.g. in /etc/default/jenkins!
{{< /hint >}}

```nginx
      location ^~ /jenkins/ {
        proxy_pass http://xxx.xxx.xxx.xxx:8080/jenkins/;
        proxy_set_header   Host             $host:$server_port;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_max_temp_file_size 0;
        client_max_body_size       10m;
        client_body_buffer_size    128k;
        proxy_connect_timeout      90;
        proxy_send_timeout         90;
        proxy_read_timeout         90;
        proxy_temp_file_write_size 64k;
        proxy_http_version 1.1;
        proxy_request_buffering off;
        proxy_buffering off;
      }
```

In case of bad proxy configuration warning in Jenkins ensure that the `Jenkins URL` in the settings ist with port number!

## Setup Git, Maven, JDK, Docker, and Co

Configure multiple Versions in "Manage Jenkins" - > "Configure Global Tools". When nothing is configured the system defaults will be used. When one entry is present this one will be used. If multiple versions are configured you can select the version in your job settings

## Ldap troubleshooting

`User search filter`: (&(objectCategory=person)(sAMAccountName={0})) `Root exception is java.net.UnknownHostException: DomainDnsZones` LDAP answers the request with other systems which might have further information but cannot be resolved. Set a variable `java.naming.referral`to `ignore`. `PartialResultException`: You have to narrow down your root DN

More [here](https://issues.jenkins-ci.org/browse/JENKINS-4895) and [here](https://issues.jenkins-ci.org/browse/JENKINS-8569)

## Jenkins auto config at deployment

Preconfigure a fresh Jenkins instance for example via Docker images:

```bash
# disablae startup wizard
echo -n "2.0" > "$JENKINS_HOME"/jenkins.install.InstallUtil.lastExecVersion

# copy initial settings
cp -r /usr/share/jenkins/ref/init.groovy.d/ "$JENKINS_HOME"
```

/usr/share/jenkins/ref/init.groovy.d/ 01-basic-settings.groovy

```groovy
#!groovy
import hudson.security.*
import jenkins.security.s2m.*
import jenkins.model.*
import hudson.security.csrf.DefaultCrumbIssuer

def pass_string = org.apache.commons.lang.RandomStringUtils.randomAlphanumeric(10)
def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()

// create admin user
hudsonRealm.createAccount("admin", pass_string)
instance.setSecurityRealm(hudsonRealm)
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
println "========================================================================="
println "Your password for jenkins user \"admin\" is $pass_string"
println "Please safe this randomly generated password or better set a new password"
println "========================================================================="

// Use only secure JNLP4 Protocol
Set<String> agentProtocolsList = ['JNLP4-connect', 'Ping']
if(!instance.getAgentProtocols().equals(agentProtocolsList)) {
    instance.setAgentProtocols(agentProtocolsList)
    println "Agent Protocols have changed.  Setting: ${agentProtocolsList}"
}
else {
    println "Nothing changed.  Agent Protocols already configured: ${instance.getAgentProtocols()}"
}

// Enable CSRF Protection
if(instance.getCrumbIssuer() == null) {
    instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
    println 'CSRF Protection configuration has changed.  Enabled CSRF Protection.'
}
else {
    println 'Nothing changed.  CSRF Protection already configured.'
}

// Disable usage statistics
if(instance.isUsageStatisticsCollected()){
    instance.setNoUsageStatistics(true)
    println 'Disabled submitting usage stats to Jenkins project.'
}
else {
    println 'Nothing changed.  Usage stats are not submitted to the Jenkins project.'
}

// Enable Agent to master security subsystem
instance.injector.getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false);
instance.save()
```

## Global vars

List of available global vars: https://JENKINS_URL/pipeline-syntax/globals

Define your own global vars in "Configure System" -> **Global Pipeline Libraries**.

### Repository structure

- ressources directory can have non-groovy resources, e.g. json, that get loaded via the libraryResource step.
- src directory uses a structure similar to the standard Java src layout and is added to the classpath when a Pipeline that includes this shared library is executed.
- vars directory holds global variables that should be accessible from pipeline scripts. A corresponding .txt file can be included that defines documentation for objects here.

Example for vars file named `deployment.groovy`:

```groovy
def call(args) {
    if( args == "deploy") {
        lastBuild = ( ${env.BUILD_ID} as int) - 1
        sh "docker-compose pull"
        sh "docker-compose -p ${env.JOB_NAME}-${lastBuild} up --force-recreate --no-color  -d"
    }
    if( args == "remove") {
        LastBuild = env.BUILD_ID - 1
        sh "docker-compose -p ${env.JOB_NAME}-${LastBuild} down --remove-orphans"
        sh "docker-compose rm -f"
    }
}
```

### Usage

In your Jenkinsfile

```groovy
library ('LIBRARY_NAME') // At the beginning
...
stages {
   stage ('prepare') {
        steps {
            deployment('remove') // name of the file of the shared library
        }
    }
...
}
```

[Reference](https://jenkins.io/doc/book/pipeline/shared-libraries/)

## Jenkinsfile

### Enable git tag / push with ssh on jenkins slaves

Install [SSHAgent Plugin](https://wiki.jenkins.io/display/JENKINS/SSH+Agent+Plugin).

```groovy
def gt(args) {
    sshagent(['13fa2-gg251as-135tasf1-sa2']) {
                    sh "git ${args}"
                }
}
```

The cryptic number represents the ID of the credentials saved in the credential store of Jenkins

### Use credentials in your pipeline

```groovy
environment {
	NEXUS_CREDS = credentials('developer')
}
```

The name is the ID of the credential. Then the following three variables are automatically available:

- NEXUS_CREDS_USR (the username)
- NEXUS_CREDS_PSW (the password)
- NEXUS_CREDS (username:password)
