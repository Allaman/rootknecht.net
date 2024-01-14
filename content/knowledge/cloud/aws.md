---
title: AWS
summary: Notes on working with AWS
---

## Tooling

- [awless](https://github.com/wallix/awless)
- [bash-my-aws](https://github.com/bash-my-aws/bash-my-aws)
- [commandeer](https://getcommandeer.com/)

## RDS instance

```
# create snapshot
aws rds create-db-snapshot --db-instance-identifier <INSTANCE_IDENTIFIER> --db-snapshot-identifier <SNAPSHOT_IDENTIFIER>
# verify snapshot
aws rds describe-db-snapshots --db-snapshot-identifier <SNAPSHOT_IDENTIFIER>
# create encrypted snapshot by copying
aws rds copy-db-snapshot --source-db-snapshot-identifier <SNAPSHOT_IDENTIFIER> --target-db-snapshot-identifier <ENCRYPTED_SNAPSHOT_IDENTIFIER> --kms-key-id <KEY_ID>
# delete instance
aws rds delete-db-instance --db-instance-identifier <INSTANCE_IDENTIFIER> --skip-final-snapshot --no-delete-automated-backup
```

## EC2

```
# Connect to EC2 instance via SSM
aws ssm start-session --target <INSTANCE_ID>  --profile <PROFILE>
```

## Secrets manager

```
# Immediately delete a secret from secrets manager
aws --profile <PROFILE> secretsmanager delete-secret --force-delete-without-recovery --secret-id <SECRET_NAME>
# Create a secret from json
aws --profile <PROFILE> secretsmanager create-secret --name <NAME> --description 'FooBar' --secret-string file://secrets.json
```

## AMI

```
# create
aws ec2 create-image --no-reboot --instance-id <INSTANCE_ID> --name "FOO" --description "BAR"
# verify
aws ec2 describe-images --image-ids <AMI_ID>
```

## Volumes

```
# stop instance
# for ASG change min=0 desired=0 and set instance to standby
aws ec2 stop-instances --instance-ids <INSTANCE_ID>
# detach volume from instance
aws ec2 detach-volume --volume-id <VOLUME_ID>
# create snapshot
aws ec2 create-snapshot --volume-id <VOLUME_ID> --description "FOO"
# verify vol
aws ec2 describe-snapshots --snapshot-ids <SNAPSHOT_ID>
# create encrypted vol
aws ec2 create-volume --snapshot-id <SNAPSHOT_ID> --volume-type gp2 --encrypted --availability-zone us-east-1a
# reattach vol
aws ec2 attach-volume --volume-id <NEW_SNAPSHOT_ID>--instance-id <INSTANCE_ID> --device /dev/sda1
```

## Optiongroup

| Terraform      | AWS Console |
| -------------- | ----------- |
| immediate      | dynamic     |
| pending-reboot | static      |

## Search vpc dependencies

```sh
#!/bin/bash
vpc="$1"
aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep InternetGatewayId
aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$vpc | grep SubnetId
aws ec2 describe-route-tables --filters 'Name=vpc-id,Values='$vpc | grep RouteTableId
aws ec2 describe-network-acls --filters 'Name=vpc-id,Values='$vpc | grep NetworkAclId
aws ec2 describe-vpc-peering-connections --filters 'Name=requester-vpc-info.vpc-id,Values='$vpc | grep VpcPeeringConnectionId
aws ec2 describe-vpc-endpoints --filters 'Name=vpc-id,Values='$vpc | grep VpcEndpointId
aws ec2 describe-nat-gateways --filter 'Name=vpc-id,Values='$vpc | grep NatGatewayId
aws ec2 describe-security-groups --filters 'Name=vpc-id,Values='$vpc | grep GroupId
aws ec2 describe-instances --filters 'Name=vpc-id,Values='$vpc | grep InstanceId
aws ec2 describe-vpn-connections --filters 'Name=vpc-id,Values='$vpc | grep VpnConnectionId
aws ec2 describe-vpn-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep VpnGatewayId
aws ec2 describe-network-interfaces --filters 'Name=vpc-id,Values='$vpc | grep NetworkInterfaceId
```
