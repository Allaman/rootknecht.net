---
title: Netzwerkressourcen einer Webseite per Skript auflisten
summary: Aufgrund eines kürzlich erhaltenen Abmahnschreibens wegen der Einbindung von Google Fonts schrieb ich ein kleines Python-Skript, das die von einer Webseite geladenen Ressourcen, wie Schriften, prüft.
description: webschriften, compliance, datenschutz, webentwicklung
date: 2022-11-02
tags:
  - web
  - programming
  - tools
---

{{< alert >}}
Dieser Beitrag wurde von einer KI ins Deutsche übersetzt. Der englische Originalinhalt wurde von mir verfasst. [Zum englischen Original](https://rootknecht.net/blog/network-resources/)
{{< /alert >}}

{{< alert >}}
Es gibt keine Gewähr für diesen Code. Das gesagt, könnte Ihre Seite komplex genug sein, dass dieses Skript nicht alle Ressourcen erkennt. Überprüfen Sie Ihr Setup immer doppelt oder dreifach und konsultieren Sie einen Anwalt.
{{< /alert >}}

## Webbrowser

Eine einfache Methode, die geladenen Ressourcen einer Website zu überprüfen, sind die Entwicklertools des Browsers. Der folgende Screenshot zeigt Firefox und den Netzwerk-Tab beim Laden dieser Webseite. Außerdem habe ich nach dem Begriff „font" gefiltert.

{{< figure src=dev-tools.png caption="Firefox-Entwicklertools filtern Schriften für diese Seite" >}}

Wie zu sehen ist, lädt diese Homepage zwei Schriften vom selben Host, von dem die Homepage bereitgestellt wird. Der Browser muss keine Verbindung zu Dritten herstellen, um die benötigten Schriften herunterzuladen. Sie werden vom gleichen Host wie die Webseite bereitgestellt.

Da ich ein Nerd bin, fragte ich mich, ob es möglich wäre, die Informationen des Netzwerk-Tabs meines Browsers programmatisch über die CLI abzurufen, was weitere Verarbeitung mit Unix-Tools ermöglicht.

## Ein CLI-Tool schreiben

Da moderne Webseiten viele Dinge tun, reicht es nicht aus, nur ein `GET` auf die URL durchzuführen, da dies nicht alle Ressourcen lädt, die ein Browser laden würde! Wir brauchen etwas, das einen Browser ausführen kann. Glücklicherweise ist das eine gängige Aufgabe beim Frontend-Testing, und es gibt ein ausgereiftes Framework, das genau das tut: [Selenium](https://www.selenium.dev/). Insbesondere [selenium-wire](https://pypi.org/project/selenium-wire/) ist ein Modul für die Arbeit mit dem Traffic, den ein Browser empfängt.

Unsere Anwendungsfälle sind:

1. Einen Headless-Browser ausführen, der eine Webseite lädt
2. Die von dieser Webseite geladenen Ressourcen abrufen
3. Die Domain der Webseite mit der Domain jeder Ressource vergleichen

Hier ist das kleine (hackige) Skript, das ich mir ausgedacht habe. Es erfordert [Firefox](https://www.mozilla.org/en-US/firefox/new/) (mein bevorzugter Browser), [geckodriver](https://github.com/mozilla/geckodriver/releases/) (in PATH einfügen) und `selenium` sowie `selenium-wire` und einige Hilfsmodule (`pip install --user selenium selenium-wire blinker==1.7.0 packaging setuptools`).

```python
from seleniumwire import webdriver
from urllib.parse import urlparse
import argparse


def getDomain(s):
    return urlparse(s).netloc


def notHomePageInResource(homepage, res):
    return getDomain(homepage) not in getDomain(res)


def getNetworkResources(homepage):
    options = webdriver.FirefoxOptions()
    # options.headless = True # ältere Versionen
    options.add_argument("--headless")
    options.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 \
        (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
    )
    driver = webdriver.Firefox(options=options) # Anwendungsfall 1
    driver.implicitly_wait(20)
    resources = []

    driver.get(homepage)

    # https://support.mozilla.org/en-US/questions/1251590
    excluded_resource = ["firefox.com", "mozilla.com", "mozilla.net"]
    for request in driver.requests: # Anwendungsfall 2
        if request.response:
            if not [e for e in excluded_resource if e in request.url]:
                resources.append(request.url)

    return set(resources)


def checkResources(homepage, resources):
    for res in resources:
        if notHomePageInResource(homepage, res): # Anwendungsfall 3
            print(res)


def dumpResources(resources):
    for res in resources:
        print(res)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="network-resources",
        description="Verify resources that webpages will load",
    )
    parser.add_argument("url", action="store", nargs="+", help="URL(s) to check")
    parser.add_argument(
        "-c",
        "--check",
        action="store_true",
        help="List resources loaded from third party domains",
    )
    args = parser.parse_args()

    for u in args.url[1:]:
        r = getNetworkResources(u)
        if args.check:
            print(f"Checking {u}")
            checkResources(u, r)
            print(f"Finished with {u}\n")
        else:
            print(f"Dumping {u}")
            dumpResources(r)
            print(f"Finished with {u}\n")
```

Das Ausführen von `python network-resources url "https://rootknecht.net"` listet alle von einer Webseite geladenen Ressourcen auf:

{{< figure src=fonts.png caption="Die gleiche Ausgabe wie mit Firefox-Entwicklertools" >}}

Das Ausführen von `python network-resources -c url "https://google.com"` prüft die Domain der Homepage und die der Ressourcen:

{{< figure src=check.png caption="Prüfung auf Drittanbieter-Ressourcen" >}}

Hier ist zu sehen, dass google.com einige Assets von einer anderen Domain als google.com lädt.

Mehrere URLs können auch gleichzeitig angegeben werden:

{{< figure src=multiple.png caption="Liste von URLs" >}}

Mit diesem Skript können Ressourcen, die von einer Webseite geladen werden, überprüft werden, ohne die geliebte Shell zu verlassen 🚀

## Einschränkungen

Moderne Webseiten sind komplex, und es ist für Selenium nicht einfach zu entscheiden, ob eine Webseite vollständig geladen ist. Dieser einfache Ansatz ist also nicht 100% genau, aber für ein kleines Spielzeugprojekt war er ziemlich spaßig und erfüllt meinen Bedarf 😊
