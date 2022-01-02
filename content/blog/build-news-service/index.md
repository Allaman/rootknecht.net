---
title: Building your own news service with Huginn
type: posts
draft: false
date: 2022-01-02
tags:
  - diy
  - tools
  - web
resources:
  - name: head
    src: head.jpeg
  - name: agents
    src: agents.png
    title: Overview of all of my agents
  - name: new-agent
    src: new-agent.png
    title: The new website agent form
  - name: inspect
    src: inspect.png
    title: Inspecting the headline of the latest Docker blog post (Firefox)
  - name: dry-run
    src: dry-run.png
    title: Dry run of the applied Go Blog agent returning the title and link of the latest post
  - name: data-agent
    src: data-agent.png
    title: The new data output agent form
  - name: feed-url
    src: feed-url.png
    title: RSS feed url for your RSS reader
---

I am (still) a big fan of RSS feeds and have built a neat collection of feeds on my self-hosted [Tiny Tiny RSS](https://tt-rss.org/). However, not all interesting blogs do offer an RSS feed. In this post, I will show you how I generate my own RSS feed from those blogs via [Huginn](https://github.com/huginn/huginn).

<!--more-->

{{< toc >}}

## Huginn

### What is it?

[Huginn](https://github.com/huginn/huginn) describes itself as

> Huginn is a system for building agents that perform automated tasks for you online.

> Think of it as a hackable version of IFTTT or Zapier on your own server

In other words: Huginn provides agents of various types that can perform different tasks. They can run periodically or can be triggered. The output of one task can be the input of another task, allowing you to build complex flows.

### Deployment

I deploy Huginn via docker-compose on my root server. You can deploy Huginn to almost anything like your home lab, a Raspberry Pi, etc. See [the docs](https://github.com/huginn/huginn/wiki#deploying-huginn) for other methods.

```yaml
version: '3'
services:
  huginn:
    image: huginn/huginn
    restart: always
    container_name: huginn
    ports:
      - 127.0.0.1:3001:3000
    volumes:
      - /home/michael/huginn/mysql-data:/var/lib/mysql
    environment:
      # Don't create the default "admin" user with password "password".
      DO_NOT_SEED: "true"
      ENABLE_INSECURE_AGENTS: "true"
      DELAYED_JOB_MAX_RUNTIME: 5
      DELAYED_JOB_MAX_RUNTIME: 100
      # General Configuration
      INVITATION_CODE: XXX
      TIMEZONE: Berlin
      # Email Configuration (only for mail instead of RSS needed)
      SMTP_DOMAIN: XXX
      EMAIL_FROM_ADDRESS: Huginn <XXX>
      SMTP_USER_NAME: "XXX"
      SMTP_PASSWORD: "XXX"
      SMTP_SERVER: "XXX"
      SMTP_PORT: "587"
```

## Build your news service

Now, let's have a look how to create your news feed. We need to gather new posts and publish an RSS feed from them. The following picture illustrates my setup:

{{< img name=agents lazy=true size=small >}}

### Gather new posts

To gather data from websites, Huginn has the `Website Agent`

> The Website Agent scrapes a website, XML document, or JSON feed and creates Events based on the results.

In the following example, we want to get new blog posts from https://appliedgo.com/blog. The full JSON config is at the end of this chapter.

After creating a new agent via the agent's menu, you have some general options and the agent's settings on the left side. On the right side you find the documentation of the agent with all its options.

{{< img name=new-agent lazy=true size=small >}}

For our purpose we just enter a name and set the desired schedule of the agent.

{{< hint warning >}}
Be conservative with your agent and do not generate unnecessary load!
{{< /hint >}}

The interesting part is the scrape config of the agent after the general settings. You can hit `toggle view` to switch to the JSON view.

Now, we want to extract the `title` and the `link` elements because that is sufficient for our needs. We will use the XPath of the according element to tell the agent what data to extract. You can specify the content you want to extract via `xpath` or `css` (CSS selector in your browser).

To get the path of the element open the dev tools in your browser, hit the "inspect" button, hover over the element (the headline) and left-click. The you can copy the path of the highlighted code section.

{{< img name=inspect lazy=true size=small >}}

{{< hint warning >}}
Obviously, these methods are not as stable as a regular API and there is a high chance that there will break something with your paths. You can set the `expected_update_period_in_days` value to a number you would expect to gather a new post. If there is no post in this time period, for example due to changes in the paths, Huginn will mark the agent as "not working" (but continue to run it).
{{< /hint >}}

To get the value of the headline we use `./node()` and to get the value of the link we use `@href`.

When a link is only relative we can't click on it from our feed, so we need to prefix the blog path with the host. The `template` section "builds" the output of the agent.

Additionally, We must check that the `mode` is set to `on_change`. With this setting in place, Huginn watches only for changes of the payload. This ensures that we are ignoring old posts that were already processed by Huginn.

The following JSON shows the configuration for the agent:

```json
{
  "expected_update_period_in_days": "30",
  "url": "https://appliedgo.com/blog",
  "type": "html",
  "mode": "on_change",
  "extract": {
    "title": {
      "xpath": "/html/body/div[1]/div[3]/div/div/div[2]/div[1]/div/div/a[2]/h3",
      "value": "./node()"
    },
    "link": {
      "value": "@href",
      "xpath": "/html/body/div[1]/div[3]/div/div/div[2]/div[1]/div/div/a[2]"
    }
  },
  "template": {
    "url": "https://go.dev/{{ link }}",
    "title": "{{ title }}"
  }
}
```

We can use the `Dry Run` button the test our agent.

{{< img name=dry-run lazy=true size=small >}}

### Create a RSS feed

We have an agent that can extract data, but nothing happens with this data. In order to process the data, we utilize the feature that one agent's output can be the input of another agent.

We create a new agent of type `Data Output Agent`. Then, ee give the agent a name and add our website agent to the `Soures` option. Furthermore, we also need to change the secret-key in the options. This will be part of the URL and should be kept private if your Huginn instance is public.

{{< img name=data-agent lazy=true size=small >}}

After saving the agent we ca see the URL in the agent's summary view. We can subscribe with a RSS reader of our choice with that URL.

{{< img name=feed-url lazy=true size=small >}}

### Alternative: Mail

If you are not into RSS you can Huginn let you notify via Mail.

{{< hint info >}}
Ensure that you have configured your SMTP settings in Huginn!
{{< /hint >}}

Create a new agent of type `Email Agent`. Give your agent a name, add your website agent as `Source`, and configure your mail headline and subject. Save the agent and your agent will wait for events from your website agent to mail to your Huginn account's default mail. To specify a mail address, we can set the `recipient` key in the options.

## Conclusion

In this post, we created our own news service from blogs that do not offer RSS feeds or only newsletters via mail. With this approach, you don't have to subscribe to a newsletter or manually check all interesting blogs.
However, this solution requires some technical knowledge and effort and there might be easier ways to accomplish this. Nevertheless, I like the advantage of having full control over each aspect.

{{< hint info >}}
Please keep also in mind that we only scratched the surface of what Huginn is able to do!
{{< /hint >}}
