---
title: Hands-on Nomad
summary: "Ich arbeite seit Jahren mit Kubernetes als Container-Orchestrierungstool. Obwohl ich Kubernetes für ein großartiges Tool halte, wenn es die Probleme löst, für die es gedacht ist, bringt es auch – zumindest ein :grinning_face: – Problem mit sich: Kubernetes ist ein komplexes Tool, das sowohl im Betrieb als auch in der Nutzung aufwändig ist. In diesem Beitrag beschreibe ich meine ersten Schritte mit Nomad von HashiCorp, das verspricht, weniger komplex als Kubernetes zu sein."
description: nomad, kubernetes, hands-on, docker, jvm
date: 2023-08-15
tags:
  - devops
  - tools
  - cloud
  - docker
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/hands-on-nomad/)
{{< /alert >}}

## Was ist Nomad

> A simple and flexible scheduler and orchestrator to deploy and manage containers and non-containerized applications across on-prem and clouds at scale.

Besonders die „nicht containerisierten" Anwendungen sind ein interessantes Feature. Man kann z. B. eine JVM-basierte App ohne eine zusätzliche Docker-Schicht ausführen.

> Nomad runs as a single binary with a small resource footprint ...

Ich mag wirklich die Einfachheit, Anwendungen bereitzustellen, die nur aus einem einzigen Binary bestehen!

## Ziele

Um ein Gefühl für Nomad zu bekommen, habe ich mir folgende Fragen gestellt:

1. Wie erstelle ich einen einfachen Nomad-Cluster, um ein Gefühl für die Technologie zu bekommen?
1. Wie richte ich einen Authentifizierungsmechanismus ein?
1. Wie deploye ich verschiedene Arten von Workloads?
1. Wie leite ich Traffic innerhalb des Clusters weiter?
1. Wie isoliere ich Entwickler von bestimmten Aktionen oder Ressourcen?
1. Kann ich das ohne [Consul](https://www.consul.io/) und [Vault](https://www.vaultproject.io/) von HashiCorp erreichen[^1]?

Noch nicht in Scope sind folgende Themen:

1. Nomads Enterprise-Features.
1. Betrieb von Nomad auf Cloud-Infrastruktur.
1. Auto-Scaling von Nodes.
1. Multi-Region-Federation.
1. Nomad und Vault-Integration.

Im Laufe dieses Blogbeitrags werde ich all diese Fragen angehen und hoffentlich einige Antworten liefern. Los geht's! 🚀

{{< alert >}}
Den Quellcode aus diesem Blogbeitrag findet man in meinem Repository [hands-on-nomad](https://github.com/Allaman/hands-on-nomad) auf GitHub.
{{< /alert >}}

## Einen Nomad-Cluster erstellen

Denken Sie daran: Mein Ziel ist nicht, einen hochverfügbaren, multi-regionalen, ausfallredundanten Cluster zu erstellen, sondern den einfachsten Cluster, um ein Gefühl für Nomad zu bekommen und es möglicherweise für unkritische (persönliche) Workloads zu nutzen. Es gibt auch viele Repos, die sich mit der Erstellung eines Nomad-Clusters befassen, indem sie ein Ansible-Playbook oder Terraform-Dateien für einen Cloud-Anbieter bereitstellen. Ohne diese Repos zu bewerten, entschied ich mich, es grundlegend zu halten und einfach ein nicht ausgefeiltes [Bash-Skript](https://github.com/Allaman/hands-on-nomad/blob/main/bootstrap.sh) zu schreiben.

Indem ich jeden Befehl Schritt für Schritt ausführe und sie in einem Bash-Skript „dokumentiere", lerne ich Nomad meiner Meinung nach effektiver. Ich glaube, dass man sich, bevor man Dinge automatisiert oder eine Art „geskriptete" Lösung verwendet, die Hände schmutzig machen und den manuellen Weg gehen muss.

Wie bereits erwähnt, ist Nomad nur ein einziges Binary[^2], daher ist die Installation so einfach wie das Herunterladen des Binaries. Ich habe mich jedoch entschieden, Nomad mit dem Paketmanager meines Debian-Systems zu installieren.

Ich werde auch Docker und OpenJDK installieren, damit ich Workloads beider Typen ausführen kann.

{{< alert >}}
Alle verfügbaren Treiber sind in der [Dokumentation](https://developer.hashicorp.com/nomad/docs/drivers) aufgeführt.
{{< /alert >}}

Die Konfigurationsdatei für den Cluster (generiert durch das Bootstrap-Skript) ist wie folgt:

```hcl
log_level = "DEBUG"
acl {
  enabled = true
}
client {
  enabled = true
}
server {
  enabled = true
  bootstrap_expect = 1
}
datacenter = "dc1"
data_dir = "/opt/nomad"
name =  "example.com"
```

Damit werden die Rollen „server" und „client" auf einem Single-Node-Cluster aktiviert. Nochmals: Das ist keine Konfiguration für ein Produktions-Setup! Außerdem möchte ich [ACL](https://developer.hashicorp.com/nomad/tutorials/access-control/access-control) aktivieren.

Zusätzlich erstellt mein kleines Bootstrap-Skript eine `systemd`-Unit, um Nomad bequem als Dienst zu starten/stoppen/neu zu starten.

Der letzte Schritt des Skripts besteht darin, [die ACL-Fähigkeiten des Clusters zu bootstrappen](https://developer.hashicorp.com/nomad/tutorials/access-control/access-control-bootstrap). Dieser Befehl speichert den ersten sogenannten „Management Token" (auch Admin-Berechtigungen in Nomad) in einer Datei namens `bootstrap.token`. Dieser Token kann auf den lokalen Rechner kopiert und mit dem bereitgestellten Makefile verwendet werden.

Nomad sollte jetzt über `http://<IHRE_IP>:4646/` erreichbar sein.

Standardmäßig hat Nomad eine „Alles verweigern"-Philosophie. Durch Aktivieren von ACL habe ich mich aus dem Cluster ausgesperrt. Im nächsten Abschnitt werde ich einen Blick auf Nomads ACL-System werfen.

## Authentifizierung und ACL

Nomads Dokumentation zu [ACL](https://developer.hashicorp.com/nomad/tutorials/access-control/access-control) ist ziemlich gut, daher werde ich sie hier nicht wiederholen. Um fortzufahren, entschied ich mich, den generierten Management-Token aus dem ACL-Bootstrap als „meinen Token" zu verwenden und keinen neuen zu erstellen.

Falls ich es noch nicht erwähnt habe: Das einzelne Nomad-Binary fungiert nicht nur als Server oder Client, sondern auch als (Remote-)Cluster-CLI. Das ist umfassend!

Der Management-Token funktioniert auch als Login-Credential für die UI.

Falls etwas mehr Komfort gewünscht wird, kann eine Policy gefunden werden, die anonymen Benutzern vollständigen Zugriff gewährt (`make anonymous`). Mit Bedacht verwenden!

Auf dieses Thema wird in einem anderen Abschnitt eingegangen, wenn ich mir die Isolierung von Entwicklern und Teams ansehe.

## Workloads deployen

Auch hier ist Nomads Dokumentation zu [Jobs](https://developer.hashicorp.com/nomad/docs/job-specification) ziemlich gut, und ich werde die Dokumentation nicht wiederholen. Im Repo sind drei einfache Workloads zu finden. Zwei davon basieren auf Docker und einer ist eine Java-Spring-Boot-App.

- `hello.hcl` ist ein einfacher containerisierter (Docker) Webserver, der seine IP und seinen Port zurückgibt (`make hello`).
- `blueprint.hcl` ist eine Java-Referenzarchitektur, die über die JVM des Hosts und nicht über einen Docker-Container läuft (`make blueprint`). Weitere Details unter [Entwicklerzugriff einschränken](#limit-developer-access).
- `traefik.hcl` ist ein Anwendungs-Proxy, der im nächsten Abschnitt behandelt wird (`make traefik`).

Die Zeile `provider = "nomad"` in der Service-Definition jedes Jobs ist zu beachten. Dies weist Nomad an, die eingebaute Service-Discovery zu verwenden, die [in 1.3 eingeführt wurde](https://www.hashicorp.com/blog/nomad-1-3-adds-native-service-discovery-and-edge-workload-support). Die Standardmethode wäre `consul`.

## Routing und Load Balancing

Nach dem Deployment des `hello.hcl`-Jobs laufen drei Instanzen des Servers, jede mit einem zufälligen Port. Um auf diese Instanzen zuzugreifen und die Last auf alle zu verteilen, brauchen wir eine Art Proxy.

Es gibt einige Auswahlmöglichkeiten, und ich empfehle (nochmals) die [Dokumentation](https://developer.hashicorp.com/nomad/tutorials/load-balancing). Ich habe [Traefik](https://traefik.io/traefik/) für mein Hands-on gewählt.

Grundsätzlich muss nur `traefik.hcl` auf den Cluster angewendet werden, und es ist mit einer Ausnahme einsatzbereit. Traefik muss auf Nomad-Ressourcen zugreifen, um seine Arbeit zu erledigen und Routen zu (dynamischen) Workloads zu generieren. Denken Sie daran: In Nomad ist alles verweigert, wenn es nicht explizit erlaubt ist. Eine Lösung ist das Hinzufügen des Parameters [--providers.nomad.endpoint.token](https://doc.traefik.io/traefik/providers/nomad/#token) zur Job-Definition. Aber es gibt meiner Meinung nach eine viel elegantere Lösung: [Workload Identity](https://developer.hashicorp.com/nomad/docs/concepts/workload-identity).

Durch Bereitstellen einer [minimalen Policy für ACL](https://github.com/traefik/traefik/issues/9677) (`traefik.policy.hcl`) können wir die Policy an die Workloads „anhängen", und ihnen werden nun die entsprechenden Berechtigungen gewährt.

Das Traefik-Dashboard ist über `http://<IHRE_IP/dashboard/` erreichbar (der abschließende Schrägstrich ist obligatorisch!) mit den Zugangsdaten `admin:admin`. Die Zugangsdaten werden mit `htpasswd -c auth admin` erstellt, was einen Basic-Auth-String für den Benutzer „admin" generiert, der in einer Datei namens `auth` gespeichert wird. Dieser String wird in einer Nomad-[Variable](https://developer.hashicorp.com/nomad/docs/concepts/variables), einer sehr einfachen Vault-Alternative, gespeichert und vom Deployment referenziert:

```
{{- with nomadVar "nomad/jobs/traefik/traefik/server" }}
"{{ .BASIC_AUTH }}",
{{- end }}
```

Wenn die Jobs `hello` und/oder `blueprint` deployed wurden, sollten im Traefik-Dashboard Einträge für beide zu sehen sein. Das Load Balancing über `http://<IHRE_IP/hello/` testen. Bei jeder Anfrage sollte eine andere Portnummer zu sehen sein.

## Entwicklerzugriff einschränken

Bei der Arbeit mit verschiedenen Teams ist es oft sinnvoll, jedes Team oder jeden Entwickler auf bestimmte Ressourcen zu beschränken. In Nomad können dafür ACLs verwendet werden.

Die folgende Policy bietet einen Ausgangspunkt, um den Zugriff auf einen Namespace und einige Aktionen einzuschränken:

```
namespace "dev" {
  policy       = "read"
  capabilities = ["submit-job","dispatch-job","read-logs"]
}
```

Mit dieser Policy können wir einen Token für einen Entwickler erstellen: `nomad acl token create -name="Max Mustermann" -policy="dev"`

{{< alert >}}
Token-Management wie Rotation, Verteilung usw. ist ein Thema, das noch nicht behandelt wird.
{{< /alert >}}

Ein Entwickler kann diesen Token durch das Setzen von Umgebungsvariablen verwenden (wie im Makefile).

## Kann ich das ohne Consul und Vault machen

Bis zu diesem Punkt wurde alles ohne Consul und Vault eingerichtet. Natürlich ist das kein produktionsbereites Setup, aber ich denke, man sollte mit einem grundlegenden Ansatz beginnen, die fundamentalen Konzepte verstehen und dann entsprechend den eigenen Bedürfnissen wachsen.

## Gedanken

Dieser Abschnitt ist eine Sammlung meiner Gedanken beim Herumspielen mit Nomad. Absichtlich möchte ich nicht zwischen „dem Guten" und „dem Schlechten" unterscheiden, da mir die reale Erfahrung mit Nomad fehlt. Daher können die folgenden Punkte eher subjektiv sein oder darauf zurückzuführen sein, dass ich mit Nomad weniger erfahren bin als mit Kubernetes.

1. In Kubernetes gibt es das Konzept des internen (`Service`-Ressource) und externen (`Ingress`-Ressource) Traffics, das mir in Nomad fehlt und das anscheinend nicht so einfach zu implementieren ist[^3]. In diesem Hands-on sind das blueprint- und das hello-Deployment über Traefik (Pfad) und, wenn bekannt, direkt über den Port erreichbar.

1. Das Schreiben von Jobs via HCL unterscheidet sich nicht zu sehr von Kubernetes YAML, und die Konzepte sind ziemlich vertraut. Ich vermute jedoch, dass eine DSL langfristig robuster ist.

1. Workloads ohne Docker auszuführen ist großartig und fühlt sich in manchen Fällen sehr richtig an. Man kann viel Komplexität und Wartungsaufwand einsparen, indem man die Docker-Schicht weglässt.

1. Das Deployment und der Betrieb von Nomad fühlt sich viel einfacher an als Kubernetes, aber natürlich habe ich kein produktionsbereites HA, multi-regionales, skalierbares Setup abgedeckt.

1. Kubernetes hat scheinbar mehr Ressourcen im Web und eine größere Community. Die Suche nach Nomad-Themen fühlte sich für mich mühsamer an.

1. Ich habe nicht viel Zeit damit verbracht, zu recherchieren, wie ein deklarativer GitOps-Ansatz, wie ihn [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) oder [Flux](https://github.com/fluxcd/flux2) für Kubernetes ermöglichen, mit Nomad implementiert werden könnte[^4].

1. Es gibt kein „managed Nomad" wie EKS, AKS oder GKE (Stand August 2023), und man muss den Cluster selbst betreiben. Glücklicherweise sollte das im Vergleich zu Kubernetes nicht allzu schwer sein.

[^1]: Ich möchte nicht falsch verstanden werden – das sind ausgezeichnete Tools, aber ich möchte prüfen, wie weit ich nur mit Nomad für eine Home-Lab-Umgebung oder für unkritische Deployments komme und dabei die Komplexität absolut minimal halte.
[^2]: Für einige Netzwerkfunktionen sind zusätzliche Binaries (CNI-Plugins) erforderlich.
[^3]: Auf [Reddit](https://www.reddit.com/r/devops/comments/15eetqa/understanding_nomad_networking/) und HashiCorp [Discuss](https://discuss.hashicorp.com/t/help-me-understanding-external-networking/55143/1) nachgefragt.
[^4]: [Diskussion](https://discuss.hashicorp.com/t/gitops-workflow-with-nomad/31200/25) zu diesem Thema.
