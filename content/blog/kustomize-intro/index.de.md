---
title: Eine Einführung in Kustomize
summary: In meinen frühen Tagen mit Kustomize fehlte mir eine kompakte, praxisorientierte Anleitung zum Aufbau von Deployments mit Kustomize und zur Umsetzung gängiger Anforderungen in einem Multi-Cluster-Setup. In diesem Blogbeitrag möchte ich diese Lücke füllen und einen umfassenden Überblick über Kustomize geben.
description: tutorial, kustomize, kubernetes, best-practices
type: posts
draft: false
date: 2021-11-06
tags:
  - Kubernetes
  - devops
  - tools
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/kustomize-intro/)
{{< /alert >}}

## Was ist Kustomize

> Kubernetes native configuration management

Mit [Kustomize](https://kustomize.io/) können Kubernetes-Deployments[^1] für verschiedene Umgebungen mit unterschiedlichen Parametern definiert werden, ohne eine neue Templatesprache oder DSL erlernen zu müssen. Kustomize arbeitet mit Standard-Kubernetes-Ressourcen[^2] und wendet über sogenannte Overlays unterschiedliche Parameter für verschiedene Umgebungen an. Mehr dazu, wenn wir Kustomize genauer betrachten.

Kustomize ist in `kubectl` enthalten und auch als [eigenständige Anwendung](https://kubectl.docs.kubernetes.io/installation/kustomize/) für alle großen Plattformen verfügbar.

## Was löst Kustomize?

Grob gesagt ist Kustomize ein Tool, das beim deklarativen Schreiben von Kubernetes-Manifesten[^3] unterstützt. Man könnte fragen, worin der Unterschied zu einem einfachen `kubectl apply -f /pfad/zu/yaml/verzeichnis` besteht.

Man denke an das gängige Szenario von Teams, die in einem Multi-Cluster-Setup für verschiedene Umgebungen[^4] deployen. Zum Beispiel könnten `develop`, `test` und `production` als Umgebungen existieren. Für jede läuft ein dedizierter Kubernetes-Cluster. Anwendungen müssen auf jedem Kubernetes-Cluster deployed werden, um die erforderlichen Aufgaben wie Testen oder QA und natürlich das Betreiben von Produktionslast zu erfüllen. Die Deployments sind auf jedem Cluster nicht identisch, da die Anforderungen unterschiedlich sein können. Im Produktionscluster werden wahrscheinlich mehr Ressourcen benötigt, um die Verfügbarkeit unter hoher Last zu gewährleisten, im Gegensatz zu Develop, wo nur wenige Entwickler arbeiten.

Ein **naiver** Ansatz könnte so aussehen:

{{< mermaid class="text-center">}}
graph TD
A[Manifeste für Dev] -->|deployen| D(Develop Kubernetes)
B[Manifeste für Test] -->|deployen| E(Test Kubernetes)
C[Manifeste für Prod] -->|deployen| F(Production Kubernetes)
{{< /mermaid >}}

Für jede Umgebung werden Kubernetes-Manifeste mit den spezifischen Parametern definiert und auf den Cluster angewendet. Das führt zu viel **redundantem** Code und verringert die **Wartbarkeit**, da bei einer gemeinsamen Änderung, die alle Umgebungen betrifft, jede einzeln angepasst werden muss.

Um Code-Redundanz zu reduzieren und die Wartbarkeit zu erhöhen, möchte man folgenden Ansatz erreichen:

{{< mermaid class="text-center" >}}
graph TD
A[Manifeste] -->|individuell deployen| D(Develop Kubernetes)
A -->|individuell deployen| E(Test Kubernetes)
A -->|individuell deployen| F(Production Kubernetes)
{{< /mermaid >}}

Gemeinsame Kubernetes-Manifeste für alle Umgebungen sollen definiert werden, die für jede Umgebung **k**ustomisiert werden.

## Kustomize in der Praxis

Kustomize führt das Konzept von `base` und `overlay` ein. Die Base enthält alle Kubernetes-Manifeste, die für alle Umgebungen gelten und sich in der Regel selten oder gar nicht ändern. Der Overlay enthält Manifeste für eine bestimmte Umgebung und ändert oder ergänzt spezifische Werte der Base.

Eine gängige Praxis beim Schreiben von Kustomize-Deployments ist eine klare Ordnerstruktur, die Base- und Overlay-Manifeste trennt, wie im folgenden Bild dargestellt:

{{< figure src=folder-structure.png caption="Top-Level-Ordnerlayout" >}}

{{< alert >}}
Der Overlay-Ordner kann weggelassen werden, wenn ein flacheres Layout bevorzugt wird. Grundsätzlich können die Manifeste beliebig organisiert werden, aber es empfiehlt sich, es einfach und einheitlich über Projekte/Teams hinweg zu halten.
{{< /alert >}}

### Grundlegendes Beispiel

Dieses Beispiel veranschaulicht den einfachen Overlay-Mechanismus von Kustomize, um Kubernetes-Manifeste für verschiedene Umgebungen zu schreiben. Kustomize generiert/baut die Manifeste, bevor sie an den Kubernetes-Controller übertragen werden.

Die generierten Manifeste werden ausgegeben und können in eine Datei umgeleitet werden.

```sh
kustomize build /pfad/zum/ordner [> manifests.yaml]
```

{{< alert >}}
Der folgende Snippet wendet Ressourcen an! Den vorherigen Befehl für die reine Generierung verwenden.
{{< /alert >}}

Und wenn das eingebaute Kustomize-Flag von kubectl verwendet werden soll:

```sh
kubectl apply -k /pfad/zum/ordner
```

{{< alert >}}
Der Großteil meines Kustomize-Codes enthält ein [Makefile](https://github.com/Allaman/toolbox/tree/main/makefile/kustomize) mit gängigen Befehlen – es lohnt sich, einen Blick darauf zu werfen 🤓
{{< /alert >}}

Nun betrachten wir folgendes Szenario:

- drei Umgebungen (dev, test, prod)
- zwei Anwendungen namens foo und bar

Es sollen Deployment-Manifeste geschrieben werden, die folgende Anforderungen erfüllen:

- Beide Anwendungen sollen in jede Umgebung deployed werden
- Das Ressourcen-Labeling muss zur Umgebung passen
- Die Anwendungen sollen pro Umgebung skaliert werden
- Den Anwendungen sollen pro Umgebung Ressourcen zugewiesen werden
- ENV-Variablen sollen pro Umgebung in Pods injiziert werden

{{< alert >}}
Der Code ist auf meinem [Github](https://github.com/Allaman/kustomize-demo/tree/main/basic) zu finden.
{{< /alert >}}

Im **Base**-Ordner werden die üblichen Kubernetes-Manifeste definiert. Für diese Demo werden Ressourcen für ein Deployment, ein Service Account und einen Service für beide Dienste `bar` und `foo` geschrieben.

{{< figure src=basic/base-folder.png caption="Inhalt des Base-Ordners" >}}

Zusätzlich benötigt Kustomize in jedem Ordner eine `kustomization.yaml`, die mindestens eine Liste der von Kustomize zu verarbeitenden Ressourcendateien enthält. Zusätzlich werden gemeinsame Labels für diese Anwendung definiert.

`base/bar/kustomization.yaml`:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
commonLabels:
  app.kubernetes.io/name: bar
resources:
  - deployment.yaml
  - sa.yaml
  - service.yaml
```

Der **Overlay**-Ordner enthält die Änderungen für jede Umgebung. Auch hier benötigt jeder Ordner eine `kustomization.yaml`.

{{< figure src=basic/overlay-folder.png caption="Inhalt des Overlay-Ordners" >}}

{{< alert >}}
Am Anfang ist das etwas ungewohnt, und man vergisst wahrscheinlich oft, eine `kustomization.yaml` hinzuzufügen, aber man gewöhnt sich daran.
{{< /alert >}}

Die erste `kustomization.yaml` definiert die Liste der auf die entsprechende Umgebung anzuwendenden Ressourcen. Ordner können ebenfalls definiert werden. Außerdem wird ein zusätzliches gemeinsames Label spezifisch für die Umgebung (`env`) definiert, das zu den bereits in den Base-Ressourcen definierten Labels hinzugefügt wird.

`overlay/dev/kustomization.yaml`:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: app
commonLabels:
  env: dev
resources:
  - bar/
  - foo/
```

Die zweite `kustomization.yaml` definiert schließlich die Ressourcen, um die Werte der Anwendung zu modifizieren.

`overlay/dev/bar/kustomization.yaml`:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../base/bar/
patchesStrategicMerge:
  - deployment.yaml
```

In diesem Beispiel wird ein [patchesStrategicMerge](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/#patchstrategicmerge) verwendet, das die bereitgestellte `deployment.yaml` nimmt und die angegebenen Werte auf die in `base` definierte Deployment-Ressource anwendet.

`overlay/dev/foo/deployment.yaml`:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: foo
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: foo
          env:
            - name: ENVIRONMENT
              value: dev
          resources:
            requests:
              memory: "100Mi"
              cpu: "100m"
            limits:
              memory: "100Mi"
              cpu: "100m"
```

{{< alert >}}
Die Namen der Ressourcen (hier `metadata.name` und `containers.name`) müssen angegeben werden, damit Kustomize die Ressourcen aus der Base identifizieren kann, auf die der Patch abzielt.
{{< /alert >}}

Dieser Patch fügt `spec.replicas`, `spec.template.spec.containers[0].resources` und `spec.template.spec.containers[0].env` zur Deployment-Ressource aus der Base hinzu. Da für jede Umgebung ein solcher Patch bereitgestellt wird, kann das Deployment für jede Umgebung angepasst werden.

Hier ist ein Diff der von Kustomize für jede Umgebung generierten Deployment-Ressourcen. Wie beabsichtigt, ist jede Umgebung mit ihren eigenen Werten **k**ustomisiert.

{{< figure src=basic/diff.png caption="Diff von dev, test und prod (von links nach rechts)" >}}

### Selektoren

Bei näherer Betrachtung des Codes des grundlegenden Beispiels fällt auf, dass den Deployment-Manifesten der Teil `spec.selectors` fehlt und wie das für ein echtes Deployment in einem Cluster funktionieren soll.

Die Antwort ist eine praktische Funktion von Kustomize für die Handhabung von `spec.selectors`. Kustomize verwaltet diese automatisch!

Schauen wir uns das generierte Deployment-Manifest für den foo-Dienst an.

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: foo
    env: prod
  name: foo
  namespace: app
spec:
  replicas: 3
  selector: # automatisch von Kustomize generiert
    matchLabels:
      app.kubernetes.io/name: foo
      env: prod
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        app.kubernetes.io/name: foo
        env: prod
```

{{< alert >}}
Da Kustomize immer alle Werte von `commonLabels` für Selektoren verwendet, können Labels für bestimmte Ressourcen (z. B. Deployments) nicht geändert werden, weil `matchLabel` von der Kubernetes-API unveränderlich ist! Über das Labeling nachdenken, bevor Ressourcen deployed werden.
{{< /alert >}}

Seit Kustomize [4.1.0](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv4.1.0) gibt es eine neue Option, um zwischen Labels zu unterscheiden, die in Selektoren aufgenommen werden sollen, wie das folgende Beispiel zeigt.

`basic/base/bar/kustomization.yaml`:

```yaml
labels:
  - pairs:
      # beide Labels werden nicht in Selektoren aufgenommen
      version: 0.9.0
      msg: not in selector
      # dieses Label wird als Selektor aufgenommen
  - pairs:
      criticality: high
    includeSelectors: true
```

Durch Bereitstellen einer Menge von Base-Ressourcen kann die Anzahl redundanter Manifeste reduziert werden. Durch Anwenden von Patches über Kustomize werden nur die Ressourcenwerte geändert, die benötigt werden. Durch Einhaltung einer sauberen Ordnerstruktur (weitere Details unter [Ressourcenlayout](#resource-layout)) sind Kubernetes-Manifeste intuitiv zu verstehen und zu pflegen.

### Ressourcenlayout

{{< alert >}}
[Quellcode](https://github.com/Allaman/kustomize-demo/tree/main/layering) für die Demo

Nur Dummy-Kubernetes-Manifeste zur Demonstration
{{< /alert >}}

Kustomize arbeitet auf verschiedenen Ebenen und ermöglicht es, Deployments zu organisieren und eine logische Struktur zu erstellen. Denken wir an ein komplexeres Deployment-Szenario.

**Grundbedingungen**

- zwei dedizierte Cluster für eine Staging-(stg) und eine Produktions-(prod) Umgebung
- ein Frontend bestehend aus einer UI-Komponente und einer BFF-Komponente (Backend for Frontend)
- ein Backend bestehend aus einer Engine-Komponente, einer Administrations-Komponente und **mehreren** Scraper-Komponenten
- ein Debugging-Dienst, der nur auf stg deployed werden muss

**Implementierung**

Mit Kustomize können Deployments in Ordnern und Unterordnern in einer verschachtelten Struktur organisiert werden.

{{< figure name=layering/folder-structure.png caption="Struktur eines komplexeren Deployments" >}}

Die Anwendungen sind in den Ordnern `backend` und `frontend` organisiert. Natürlich benötigt jeder Ordner eine `kustomization.yaml`. Außerdem ist zu sehen, dass die Anwendung `debug` nur in stg und nicht in der Base existiert, da sie laut Anforderungen nur dort benötigt wird. Wenn es die Möglichkeit gibt, dass die Debug-Komponente auch in prod deployed werden muss, kann sie in der Base definiert werden, aber nur von Staging aus referenziert werden.

#### Labels

Labels werden durch den Pfad zusammengeführt, den Kustomize durchläuft, und in jeder `kustomization.yaml` können neue Labels hinzugefügt werden (falls nötig).

{{< mermaid class="text-center" >}}
graph TD
A[overlay/prod/kustomization.yaml] --> B[overlay/prod/backend/kustomization.yaml]
B --> C[overlay/prod/backend/editor/kustomization.yaml]
C --> D[base/backend/editor/kustomization.yaml]
{{< /mermaid >}}

Die Labels, nachdem Kustomize das Manifest gebaut hat, sind wie folgt:

```yaml
labels:
  app.kubernetes.io/name: editor # aus /base/backend/editor/kustomization.yaml
  app.kubernetes.io/part-of: backend # aus base/backend/kustomization.yaml
  env: prod # aus prod/kustomization.yaml
```

#### Mehrere Deployments aus einer Base

In Produktion sollen mehrere Scraper-Anwendungen deployed werden, die möglicherweise nur in einer leicht unterschiedlichen Konfiguration laufen (z. B. eine andere Umgebungsvariable). Mit Kustomize können die gemeinsamen Ressourcen für den Scraper weiterhin im Base-Ordner definiert werden, aber mehrere Deployments im Overlay erstellt werden.

{{< figure src=layering/backend-structure.png caption="Deployments aus derselben Base" >}}

Wie funktioniert das und wie werden Namenskollisionen bei Ressourcen vermieden?

Kustomize hat eine Funktion `nameSuffix` (und `namePrefix`), die alle Ressourcennamen entsprechend ändert:

`layering/overlay/prod/backend/scraper-bar/kustomization.yaml`

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
nameSuffix: -bar
commonLabels:
  app.kubernetes.io/name: scraper-bar
resources:
  - ../../../../base/backend/scraper
```

Obwohl in der Base `metadata.name: scraper` definiert wurde, generiert Kustomize Manifeste mit einem neuen Namen, was das Deployen mehrerer Scraper-Anwendungen ermöglicht, während nur eine gemeinsame Base gepflegt wird.

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/name: scraper-foo
    app.kubernetes.io/part-of: backend
    env: prod
  name: scraper-foo # aus nameSuffix in kustomization.yaml
  namespace: team1
```

### Weitere Kustomisierung

Kustomize unterstützt neben `patchesStrategicMerge` weitere fortgeschrittene Mechanismen.

{{< alert >}}
Der Code ist auf meinem [Github](https://github.com/Allaman/kustomize-demo/tree/main/advanced) zu finden.
{{< /alert >}}

#### patches

Dieses Beispiel zeigt, wie ein einzelner Wert gepatcht (ersetzt) werden kann, in diesem Fall der Host einer Ingress-Ressource.

{{< figure src=advanced/host-example.png caption="Host für stg und prod" >}}

#### patchesJson6902

Dieses Beispiel ändert den Benutzernamen eines Grafana-Benachrichtigungskanals pro Umgebung:

{{< figure src=advanced/notification-example.png caption="Benutzername für stg und prod" >}}

Mehrere Werte können gepatcht und ein JSON-Format verwendet werden. Verschiedene Werte für `op`, wie delete, sind verfügbar.

```json
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--override"
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "default.replication.factor=3"
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--override"
  }
]
```

### CD-Integration

Eine CD-Integration ist für gängige GitOps-Tools wie [Flux](https://github.com/fluxcd/flux) und [ArgoCD](https://github.com/argoproj/argo-cd) verfügbar.
Aufgrund seiner Einfachheit lässt sich Kustomize wahrscheinlich auch in bestehende Workflows integrieren. Dies ist der grundlegendste Befehl zur Anwendung von Manifesten:

```sh
kustomize build overlay/prod | kubectl apply -f -
```

Zu beachten ist, dass dieser Ansatz keine Garbage Collection von Ressourcen durchführt, wie es Flux tut.

## Kustomize Best Practices

{{< alert >}}
Diese Dinge haben für mich funktioniert, aber die eigenen spezifischen Einstellungen sollten immer berücksichtigt werden!
{{< /alert >}}

1. Namenskonventionen für Dateien und Ressourcen
2. Eine Art Ressource pro YAML-Datei
3. Über Labels nachdenken ([empfohlene Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/))
4. Über die Ordnerstruktur nachdenken und sie einfach und einheitlich über Projekte/Teams hinweg halten
5. Commit-Nachrichten mit Präfix versehen, um Commits für bestimmte Umgebungen zu unterscheiden
6. Über die Base nachdenken. Im Zweifelsfall Code in den Overlay verschieben, um die Auswirkungen auf die Produktionsumgebung zu reduzieren.
7. Eine Pipeline implementieren, die die Manifeste verifiziert

## Kustomize vs. Helm

{{< alert >}}
Niemals blind einer Tool-Empfehlung folgen, sondern die spezifischen Anforderungen in der eigenen Umgebung analysieren und das beste Tool für den Job wählen!
{{< /alert >}}

### Was ist Helm

> The package manager for Kubernetes.

> Helm is the best way to find, share, and use software built for Kubernetes.

Helm ist einer der alten Akteure im Kubernetes-Ökosystem. Inzwischen ist die aktuelle Version von Helm v3, die Version 2 mit einer neuen Architektur abgelöst hat. Helm ist für alle großen Betriebssysteme [verfügbar](https://helm.sh/docs/intro/install/).

Grundsätzlich wird Helm verwendet, um Deployments für Kubernetes zu definieren und zu verteilen.

Der Hauptunterschied zu Kustomize ist die Templatesprache von Helm.

### Vergleich

{{< alert >}}
Dieser Abschnitt spiegelt meinen persönlichen Standpunkt wider!
{{< /alert >}}

| Kustomize                                                                     | Helm                                        |
| ----------------------------------------------------------------------------- | ------------------------------------------- |
| Teil von kubectl 👍                                                           | Oft von Drittanbieter-Deployments genutzt 👍|
| Basiert auf Standard-Kubernetes-Manifesten 👍                                 | Unterstützt Releases (Bundles) 👍           |
| Verschiedene Umgebungen werden mit „Overlays" konfiguriert 👍                 | Templating 👍👎                             |
| Kein Templating / keine Templatesprache 👍 👎                                 | Nicht sehr intuitiv/wartbar 👎              |
| Einfach zu schreiben und zu lesen 👍                                           | Komplexität 👎                              |
| Flexibel und anpassbar 👍                                                     | Fehleranfällig 👎                           |
| Schwierig, verschiedene Ressourcen zu bündeln 👎                              | Eigentliche Ressourcen müssen getemplated werden 👎 |
| Eigentliche Ressourcen müssen „berechnet" werden. Weitem nicht so komplex wie mit Helm 👎 | |
| Nicht so DRY 👎                                                               |                                             |

### Wann Kustomize gegenüber Helm bevorzugen

{{< alert >}}
Wie bei jeder Verallgemeinerung sollten die eigenen spezifischen Einstellungen berücksichtigt werden!
{{< /alert >}}

- Deployment in verschiedene Umgebungen
- Selbst entwickelte Microservices deployen, die in Bezug auf ihre Deployment-Abhängigkeiten lose gekoppelt sind
- Keine Verteilung der Anwendung an externe Parteien
- Keine Bündelung der Anwendung in Releases erforderlich
- Das Deployment erfordert keine komplexe Konfiguration mit Schleifen und bedingten Klauseln
- Dinge einfach halten 😉

## Nachteile von Kustomize

Es gibt einige Aspekte, die bei der Arbeit mit Kustomize zu berücksichtigen sind:

- **Boilerplate**: Bei komplexeren Deployments werden viele `kustomization.yaml`- und `version`-, `kind`-, `name`-usw.-Felder geschrieben.
- **Redundanz**: Es gibt noch etwas Redundanz. Im grundlegenden Beispiel müssen die zu patchenden Deployment-Dateien dreimal mit nur minimalen Unterschieden geschrieben werden.
- **Lose Kopplung**: Mit Kustomize definierte Komponenten sind nur lose gekoppelt, und Abhängigkeiten zwischen Komponenten lassen sich nicht leicht deklarieren.
- **Begrenzte „Sprache"**: Kustomize enthält im Gegensatz zu Helm keine Templatesprache und bietet daher keine Template-Features wie Schleifen oder Kontrollfluss.
- **Verteilung**: Die Verteilung von Anwendungen ist nicht so unkompliziert wie mit Helm.

[^1]: **Deployment**: allgemeiner Begriff für alles, was in Kubernetes deployed/installiert/betrieben werden soll.
[^2]: **Ressourcen**: Kubernetes-Objekte wie ein `configmap`, `secret`, `statefulset` usw.
[^3]: **Manifest**: Kubernetes-YAML-Dateien, die Kubernetes-Objekte/Ressourcen definieren.
[^4]: **Umgebung**: dedizierte IT-Systeme für bestimmte Schritte im Lebenszyklus. Zum Beispiel ein Staging-System für QA.
