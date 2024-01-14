---
title: Terraform
summary: Notes on working with Terraform
---

## TF exclude targets

Terraform allows to specify target modules by the `--target` option. Unfortunately, there is no option to apply everything but a certain module. The following script iterates through the directory and filters all modules. From this result a string is constructed to perform a Terraform command that excludes some target modules.

```python
#!/usr/bin/env python3
"""
This script walks recursively through a given directory (default './')
and reads all .tf files looking for 'module "FOO"' lines.
From these results and the given module names to be excluded a target string
to be used for Terraform commands printed to stdout
"""
__version__ = "1.0.0"

import argparse
import os
import re


def main(args):
    """ entry point """
    m = re.compile(r'^module "(.*?)"')
    modules = set()
    for root, dirs, files in os.walk(args.path):
        files[:] = [f for f in files if f.endswith('.tf')]
        for file in files:
            with open(os.path.join(root, file), 'r') as f:
                content = f.read()
                if m.match(content):
                    modules.add(m.match(content).group(1))
    excludes = set(args.modules)
    print(' '.join(['--target module.' + t for t in (modules-excludes)]))


if __name__ == "__main__":
    """ Executed from the commandline"""
    parser = argparse.ArgumentParser(
        description='Generate --target string from excluded modules')
    parser.add_argument('-p',
                        '--path',
                        action='store',
                        default="./",
                        help='Path of your TF root')
    parser.add_argument(
        '-v',
        action='version',
        version='%(prog)s (version {version})'.format(version=__version__))
    parser.add_argument('modules', metavar='M', type=str, nargs='+',
                        help='Name of the modules to be exlcuded')
    args = parser.parse_args()
    main(args)
```

## Manage AWS security groups

{{< alert >}}
Terraform &ge; 0.12 required due to `for_each` functionality
{{< /alert >}}

```terraform
locals {
  cidr_to_sg_rules = {
    icmp_ping = {
      type        = "ingress"
      protocol    = "icmp"
      from_port   = -1
      to_port     = -1
      cidr_blocks = [var.ping_cidr]
    }
    icmp_pong = {
      type        = "egress"
      protocol    = "icmp"
      from_port   = -1
      to_port     = -1
      cidr_blocks = [var.egress_cidr]
    }
    http_out = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = [var.egress_cidr]
    }
    https_out = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = [var.egress_cidr]
    }
  }
  sg_to_sg_rules = { for id in var.ssh_security_group_ids :
    id => {
      type         = "ingress"
      protocol     = "tcp"
      from_port    = 22
      to_port      = 22
      source_sg_id = id
    }
  }
}

resource "aws_security_group_rule" "cidr_to_sg" {
  for_each          = local.cidr_to_sg_rules
  type              = each.value["type"]
  protocol          = each.value["protocol"]
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
  cidr_blocks       = each.value["cidr_blocks"]
  security_group_id = module.foo.security_group_id
}

resource "aws_security_group_rule" "sg_to_sg" {
  for_each                 = local.sg_to_sg_rules
  type                     = each.value["type"]
  protocol                 = each.value["protocol"]
  from_port                = each.value["from_port"]
  to_port                  = each.value["to_port"]
  source_security_group_id = each.value["source_sg_id"]
  security_group_id        = module.foo.security_group_id
}
```

## Using for_each

{{< alert >}}
Terraform &ge; 0.12 required
{{< /alert >}}

```terraform
operators =   {
  "Max_Mustermann" = "system:masters",
  "Michaela_Musterfrau" = "system:masters"
}
```

```terraform
resource "aws_iam_user" "operators" {
  for_each = var.operators
  name  = each.key
  path  = "/${var.cluster_name}/"

  tags = {
    "group" = each.value
  }
}
```

```terraform
data "external" "operator_map" {
  for_each = var.operators
  program = ["python", "${path.module}/map.py"]

  query = {
    user_arn = aws_iam_user.operators[each.key].arn
    username = aws_iam_user.operators[each.key].name
    group    = each.value
  }
}
```

```terraform
output "users" {
  value = [for value in data.external.operator_map: value.result]
}
```

Conditional for_each

```terraform
  for_each = length(var.mysql_allowed_cidrs) > 0 ? local.cidr_to_sg_rules : {}
```

## Data transformation

```terraform
locals {
  user_policy_pairs = flatten([
    for policy, users in var.iam-map : [
      for user in users: {
        policy = policy
        user   = user
      }
    ]
  ])
}

output "association-map" {
  value = {
    for obj in local.user_policy_pairs : "${obj.policy}_${obj.user}" => obj
  }
}
```

<small>[source](https://discuss.hashicorp.com/t/produce-maps-from-list-of-strings-of-a-map/2197/2)</small>

## AWS Lambda

Example for creating a Lambda that deletes ES indices

**iam.tf**

```terraform
data "aws_iam_policy_document" "assume_role" {

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "es_cleanup" {
  statement {
    actions = [
      "es:ESHttpGet",
      "es:ESHttpPut",
      "es:ESHttpPost",
      "es:ESHttpHead",
      "es:ESHttpDelete",
      "es:Describe*",
      "es:List*",
    ]

    effect = "Allow"

    resources = [
      "${var.es_arn}/*"
    ]
  }
}
```

**lambda.tf**

```terraform
data "archive_file" "zipit" {
  type        = "zip"
  source_dir = "${path.module}/src/"
  output_path = "${path.module}/es_cleanup.zip"
}

resource "aws_lambda_function" "es_cleanup" {
  filename         = "${path.module}/es_cleanup.zip"
  function_name    = var.name
  description      = "es-cleanup-${var.environment}"
  runtime          = "python${var.python_version}"
  role             = "${aws_iam_role.default.arn}"
  handler          = "${var.name}.lambda_handler"
  timeout          = 20

  environment {
    variables = {
      ES_ENDPOINT             = var.es_endpoint
      ES_PORT                      = var.port
      DELETE_AFTER_UNIT = var.delete_after_unit
      DELETE_AFTER           = var.delete_after
      REGION                        = var.region
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.es_cleanup.id]
  }
}
```

**script.py**

To install the required modules to the local src folder use pip's target argument `pip install <dependency> -t .`

```python
import os
import boto3
from requests_aws4auth import AWS4Auth
from elasticsearch import Elasticsearch, RequestsHttpConnection
import curator


# Lambda execution starts here.
def lambda_handler(event, context):
    es_endpoint        = os.environ["ES_ENDPOINT"]
    es_port                = os.environ["ES_PORT"]
    delete_after         = int(os.environ["DELETE_AFTER"])
    delete_after_unit = os.environ["DELETE_AFTER_UNIT"]
    region                  = os.environ["REGION"]
    service                = 'es'

    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key,
                       region, service, session_token=credentials.token)

    # Build the Elasticsearch client.
    es = Elasticsearch(
        ["{}:{}".format(es_endpoint, es_port)],
        http_auth=awsauth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection
    )

    # Get all indices
    index_list = curator.IndexList(es)

    # Remove .kibana indices from result
    index_list.filter_by_regex(kind='suffix', value='.kibana', exclude=True)

    # Remove .FooBar indices from result
    index_list.filter_by_regex(kind='suffix', value='.FooBar', exclude=True)

    # Filter indices by age
    index_list.filter_by_age(source='creation_date', direction='older',
                             unit=delete_after_unit, unit_count=delete_after)

    print("Found %s indices" % len(index_list.indices))
    print("Found %s" % index_list.indices)
    ##########################################
    # USE WITH CARE
    # THIS CODE WILL DELETE INDICES!
    ##########################################
    # If our filtered list contains any indices, delete them.
    # if index_list.indices:
    #     curator.DeleteIndices(index_list).do_action()
```
