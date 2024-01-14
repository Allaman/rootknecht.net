---
title: Install SAP NW ABAP 7.51 Dev
summary: A guide on how to install SAP NW on your local machine
---

This article describes the installation of a SAP Netweaver 751 ABAP platform (in the following abbreviated as sapnw) for privat not commercial purpose.

{{< alert >}}
Please note that I haven't invent the wheel again. This is just a collection of guides and tutorials from other people that was working for me after some fixes. Credits goes to the creators of the content in the [Links](#links_content) section especially [wechris](https://github.com/wechris) and [Julie Plummer](https://people.sap.com/julie.plummer). in the [Additional Links](#additional_links_content) section you can find further information.
{{< /alert >}}

Essentially we will build an image for a VirtualBox appliance where sapnw will run. From there we connect with Eclipse ABAP developer tools and the SAP GUI for Netweaver. This article is assuming that your are running a Linux host machine. Nevertheless, this guide also applies on Windows machines as we are running sapnw on a virtual machine.

## Requirements

Before you continue please have a look at the requirements!

### Hardware

- x86_64 Processor based hardware
- Required: At least 8 GB RAM plus about 8 GB swap space
- Recommended: At least 16 GB RAM plus about 8 GB swap space
- About 100 GB free disk space for server installation

{{< alert >}}
The amount RAM and storage is strongly recommended!
{{< /alert >}}

### Software

For creating and running the virtual machine:

- [VirtualBox](https://www.virtualbox.org/)
- [Packer](https://www.packer.io/)
- [Vagrant](https://www.vagrantup.com/)
- Windows machines require Powershell 4

For completeness although the following software will be handled by the created virtual machine. If you want to skip the part with the virtual machine and install sapnw native on your machine make sure to fulfill these requirements.

- csh, libaio, uuidd
- LANG=en_US.UTF-8 (default system language)
- hostname max 13 chars
- FQDN (Full Qualified Domain Name)

### Client (not covered extensively in this article)

- Minimum 4 GB RAM
- Supported OS (cp. the ![Links](#Links) section)
- Oracle Java SE 8 32- or 64-bit (update 40 or newer)
- [Eclipse](http://www.eclipse.org/downloads/eclipse-packages/) for ABAP development

## Download and Extract

From [SAP](https://tools.hana.ondemand.com/#abap) download the _SAP NetWeaver AS ABAP Developer Edition_ in version _7.51 SP02_. In order to download the archives in our (linux) shell we download and accept the terms within a webbrowser with enabled network analysis tools. Then we copy the request as curl and paste it into our commandline. We append `-o part01.rar` to tell curl to save the output in a file (default is stdout). Now we can duplicate the requests and increment the numbers.

After downloading all parts we extract the archives. In Debian the package `unrar-free` does not handle multi-part archives. To install the nonfree version we must enable the nonfree repoistory by appending non-free to our main repo: `deb http://ftp.de.debian.org/debian/ jessie main non-free` and than install the package with `apt-get install unrar-nonfree`. Afterwards we extract the archives with `unrar x part01.rar`. The `x` creates the directory structure of the archive. Unrar is able to find all parts of the archives itself.

## Virtual Machine Setup

This parts shows the setup of a virtual Box according to `wechris'` image. Packer, Vagrant and Virtualbox must be installed

### Packer

Clone the code provided from wechris:

```bash
git clone https://github.com/wechris/SAPNW75SPS02.git
```

Copy the formerly **extracted** sap install files into the `sapinst` subdirectory. Then build the packer iso image:

```bash
cd packer/openSUSE-42.1/
packer build -only=virtualbox-iso template.json
```

### Vagrant

```bash
cd ../../
vagrant up --provision
```

After vagrant has finished execute `vagrant reload`

## SAP Installation

- Manually mount the shared folder ("vagrant") from your host if necessary: `mount -t vboxsf vagrant /vagrant`(see [HowTo - shared folders](https://forums.virtualbox.org/viewtopic.php?t=15868) for help)
- Install Xserver and a DE of choice (I recommend XFCE: zypper install -t pattern xfce)
- Create a CD drive, mount and install the vbox guest additions
- cd into the install (shared) folder (`/vagrant` by default)
- Make `install.sh` executable with `chmod +x install.sh`.
- Add the line `domain dummy.nodomain` to `/etc/resolv.conf` in order to start the SAPGUI installer
- Start installer with`./install.sh -g`. We must use the graphical installer as the unattended installer throws an error with a database connection. I guess that there is some kind of timeout or weird thing.
- After hitting the installer at some point it stops showing an URL which you must open in your VM's browser. This is the graphical installer which you must complete.

{{< alert >}}
After completing the installer a sapnw instance is up and running
{{< /alert >}}

## Client

In order to access sapnw from your host machine you have to edit your `hosts` file.

- Windows: Windows\System32\drivers\etc
- Linux: /etc/hosts

Add the following line

```ini
127.0.0.1 vhcalnplci.dummy.nodomain
```

Check also the port forwarding preferences of your virtual machine - all IPs must be set to 127.0.0.1 (host) and 10.0.2.15 (guest)

## Eclipse

User `DDIC` password `Appl1ance`

## SAP GUI

Sap GUI requires Oracle Java 8. Please refer to the [Oracle Download Page](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) to obtain a version for your operating system.

## Links <a id="links_content"></a>

1. [SAP 751 & 750 Download Links](https://tools.hana.ondemand.com/#abap)
1. [SAP 751 Dev Edition Download and Installation](https://blogs.sap.com/2017/09/04/sap-as-abap-7.51-sp2-developer-edition-to-download-concise-installation-guide/)
1. [SAP 751 Newbie Install Guide](https://blogs.sap.com/2017/09/04/newbies-guide-installing-abap-as-751-sp02-on-linux/)
1. [SAP 751 Concise Installation Guide](https://blogs.sap.com/2017/09/04/sap-as-abap-7.51-sp2-developer-edition-to-download-concise-installation-guide/)
1. [SAP 750 Preconfigured Vbox image](https://github.com/wechris/SAPNW75SPS02) (which is working also for version 751)

## Additional Links <a id="additional_links_content"></a>

1. [SAP Developer Tools](https://tools.hana.ondemand.com/#abap)
1. [SAP 750 Docker Image](https://github.com/tobiashofmann/sap-nw-abap-docker) not working due to "no space left on device" error of docker
1. [Oracle Java 8 Image](https://github.com/dockerfile/java)
1. [SAP GUI Docker Image](https://github.com/thalesvb/docker-platingui)
1. [SAP GUI Requirements](https://blogs.sap.com/2015/07/04/sap-gui-for-java-installation-and-configuration/)
