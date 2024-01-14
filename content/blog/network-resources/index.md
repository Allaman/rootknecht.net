---
title: List network resources of a webpage via a script
summary: Due to recent written warnings because of including Google fonts I wrote a little python script that checks the resources, like fonts, a webpage loads.
description: web font, compliance, privacy, web development
date: 2022-11-02
tags:
  - web
  - programming
  - tools
---

{{< alert >}}
There is no warranty for this code. That being said, your page might be complex enough that this script will not detect all resources. Always double or triple check your setup and consult a lawyer.
{{< /alert >}}

## Webbrowser

An easy method to check a website's loaded resources is via your browser's dev tools. The following screenshot shows Firefox and the network tab while loading this webpage. Additionally, I filtered for the string "font".

{{< figure src=dev-tools.png caption="Firefox dev tools filtering fonts for this page" >}}

As you can see, this homepage loads two fonts from the same host where the homepage is getting served from. The browser does not need to connect to a third party in order to download the required fonts. They are delivered from the same host as the webpage.

Because I am a nerd I asked myself if it would be possible to get the information of my browser's network tab programmatically in a CLI allowing me to do some further processing with Unix tooling.

## Writing a CLI tool

Because modern webpages are doing much stuff it is not sufficient to only perform a `GET` on the URL as this would not load all resources a browser would! We need something that can run a Browser. Luckily, this is a common task in frontend testing and there is a mature framework that does exactly that: [Selenium](https://www.selenium.dev/). Especially, [selenium-wire](https://pypi.org/project/selenium-wire/) is a module for working with the traffic a browser receives.

Our use cases are:

1. Run a headless browser that loads a webpage
2. Get the resources loaded from that webpages
3. Compare the domain of the webpage with each resource's domain

Here is the little (hacky) script I came up with. It requires [Firefox](https://www.mozilla.org/en-US/firefox/new/) (my browser of choice), [geckodriver](https://github.com/mozilla/geckodriver/releases/) (put it in your PATH) and `selenium` as well as `selenium-wire` (`pip install --user selenium selenium-wire`).

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
    options.headless = True
    options.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 \
        (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
    )
    driver = webdriver.Firefox(options=options) # use case 1
    driver.implicitly_wait(20)
    resources = []

    driver.get(homepage)

    # https://support.mozilla.org/en-US/questions/1251590
    excluded_resource = ["firefox.com", "mozilla.com", "mozilla.net"]
    for request in driver.requests: # use case 2
        if request.response:
            if not [e for e in excluded_resource if e in request.url]:
                resources.append(request.url)

    return set(resources)


def checkResources(homepage, resources):
    for res in resources:
        if notHomePageInResource(homepage, res): # use case 3
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

Running `python network-resources url "https://rootknecht.net"` will list all resources a webpage loads:

{{< figure src=fonts.png caption="The same output as with Firefox dev tools" >}}

Running `python network-resources -c url "https://google.com"` will check the domain of the homepage and the resources:

{{< figure src=check.png caption="Check for third party resources" >}}

Here you can see that google.com loads some assets from another domain than google.com.

You can also specify multiple URLs at once:

{{< figure src=multiple.png caption="List of URLs" >}}

With this script I can check resources loaded by a webpage without leaving my loved shell 🚀

## Limitations

Modern webpages are complex and it is not easy for Selenium to decide weather a webpage is fully loaded. So this simple approach is not 100% accurate, but for a little toy project it was quite fun and satisfies my needs 😊
