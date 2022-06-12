---
title: DevOps
type: posts
date: 2019-10-06
tags:
  - devops
  - cloud
  - infrastructure
resources:
  - name: cc
    src: "cc.png"
    title: cloud computing
---

DevOps can usually unleash its full potential in combination with [Cloud Computing](#cloud-computing) and [Infrastructure as Code](#infrastructure-as-code), which are described in the following article as well.

<!--more-->

{{< toc >}}

## Terms and definitions

{{< hint warning >}}
This page describes certain aspects in the area of DevOps. If not marked these statements are my own wording based upon my own thinking and experience without any engagement with respect to correctness and other opinions.
{{< /hint >}}

## DevOps

{{< hint info >}}
An enterprise **culture** aiming to deliver high quality software within a short lead time and high efficiency taking all the stakeholders into account.
{{< /hint >}}

### Dev vs Ops

| What Devs want       | What Ops want          |
| :------------------- | :--------------------- |
| Deliver fast         | Ensure availability    |
| Deliver frequently   | Caution                |
| Deliver new features | Stability and Security |

### Principles

**CAMS**<small> by Damon Edwards and John Willis</small>

- **C**ulture
- **A**utomation
- **M**easurement
- **S**haring

### Continuous Everything

**coming soon**

## Cloud Computing

{{< hint info >}}
Utilization of **dynamic** IT resources offered by a cloud service platform through a network.
{{< /hint >}}

### Types of Cloud Computing Services

Cloud Computing can be distinguished in _infrastructure as a Service_, _Platform as a Service_, _Software as a Service_ and _Function as a Service_. The following picture illustrated the main differences of those types and compares them to classical on premise datacenters.

{{< img name="cc" lazy="true" >}}

Examples in the Amazon ecosystem:

| Service  | Amazon Product                                                                                                   |
| :------- | :--------------------------------------------------------------------------------------------------------------- |
| IaaS     | [Amazon Web Services Elastic Compute Cloud (AWS EC2)](https://aws.amazon.com/de/ec2/?nc2=h_m1)                   |
| PaaS     | [Amazon Web Services Elastic Compute Cloud Container Service (AWS ECS)](https://aws.amazon.com/de/ecs/?nc2=h_m1) |
| FaaS     | [Amazon Web Services Lambda (AWS Lambda)](https://aws.amazon.com/lambda/)                                        |
| SaaS[^1] | [Amazon Web Services SaaS](https://aws.amazon.com/de/partners/saas-on-aws/)                                      |

### Types of Cloud Computing Delivery

| Cloud         | Characteristic                                                            |
| :------------ | :------------------------------------------------------------------------ |
| Public Cloud  | Reachable from the public internet                                        |
| Private Cloud | Dedicated cloud for a single organization manged internally or externally |
| Hybrid Cloud  | Mix of public and private cloud                                           |

### Advantages of Cloud Computing

- No need to invest in data centers
- Pay as much as you consume
- Benefit from reduced costs of scaling effects
- Reduce complexity of capacity planing
- Increase speed and agility
- More focus on business instead of infrastructure

## Infrastructure as Code

{{< hint info >}}
Automated management of the life cycle of all infrastructure components in their entirety by utilization of methods and best practices from the area of software engineering.
{{< /hint >}}

### Definition

Infrastructure as Code is an approach of infrastructure automation based on practices already established in classical software development. It emphasizes consistent, repeatable routines for provisioning and changing systems as well as their configuration. Engineers use and enforce techniques commonly known in the field of software development, such as version control systems, automated testing, deployment orchestration, test driven development, and continuous integration/delivery. Therefore, infrastructure is treated as if it is software and data.

### Challenges in the Cloud Age

1. Server Sprawl[^2]
2. Configuration Drift
3. Snowflake Servers
4. Fragile Infrastructure
5. Automation Fear
6. Erosion

### Principles

1. **Systems should be reproducible**

- minimizes the overhead and costs for all stakeholders and helps to speed up team efficiency
- minimizes automation fear and risks from making changes

2. **Systems should be disposable**

- robust, homogeneous, and well-tested infrastructure
- from unreliable software running on reliable hardware towards reliable software running on unreliable hardware

3. **Systems should be consistent**

- prevent configuration drift
- fight against automation fear

4. **Processes should be repeatable**

- disposable systems are easier to achieve as systems can be easily created multiple times.
- cost reduction, as IT staff does not waste time on repetitive tasks.

5. **Design should be flexible**

- reduce the impact of a "big bang" change.
- infrastructure is able to adopt to business needs being an enabler not a showstopper

### IaC and DevOps

Infrastructure as Code provides your DevOps teams the following benefits:

1. Develop and test against production-like systems
2. Deploy with repeatable, reliable processes
3. Monitor and validate operational quality
4. Improve quality

[^1]: Better known examples for SaaS solutions are Gmail or Office365
[^2]: According to "Infrastructure as Code - Managing Servers in the Cloud" by Kief Morris - an excellent book
