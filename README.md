
# StackSets POC

This is an example of a CloudFormation template that can be deployed in multiple [AWS regions](https://aws.amazon.com/about-aws/global-infrastructure/) in the same account using [StackSets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-concepts.html). This is a POC and definitely *not* production ready.


This POC is designed to showcase what a global deployment of a system would look like. In stack-set.cfn.yml CloudFormation template, we deploy:

* [Amazon Virtual Private Cloud](https://aws.amazon.com/vpc/)
* [Amazon EC2 Security Groups for Linux Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html)
* [Amazon EC2 Instances](https://aws.amazon.com/ec2/)
* [Auto Scaling Group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html)
* [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
* [SSL/TLS Certificates via AWS Certificate Manager](https://aws.amazon.com/certificate-manager/)
* [CloudFormation Custom Resource](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html) (to validate the TLS cert via DNS)

## Setup

Make sure you have the proper roles created:

* [Prerequisites: Granting Permissions for Stack Set Operations](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-prereqs.html)
* [3rd Party Overview)(https://sanderknape.com/2017/07/cloudformation-stacksets-automated-cross-account-region-deployments/)

Create an [Amazon EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) in each region you would like to deploy to with the *same* name. Make sure you save the private keys someplace safe.

You must have a domain hosted by [Amazon Route 53](https://aws.amazon.com/route53/).

## Deployment

Create the Stack Set:

```
aws cloudformation create-stack \
  --stack-name SOME_UNIQUE_NAME \
  --template-body file://stack-set.cfn.yml \
  --capabilities CAPABILITY_NAMED_IAM \
   --parameters \
  ParameterKey=HostedZoneName,ParameterValue=YOUR_HOSTED_ZONE \
  ParameterKey=HostedZoneId,ParameterValue=YOUR_HOSTED_ZONE_ID \
  ParameterKey=Environment,ParameterValue=dev \
  ParameterKey=KeyName,ParameterValue=YOUR_SSH_KEY_NAME
```

Create the Stack Instances:

```
aws cloudformation create-stack-instances \
  --stack-set-name NAME_USED_FOR_STACK_SET \
  --accounts YOUR_ACCOUNT_ID \
  --regions us-east-2 us-east-1
```

## Cleanup

Remove the stack instances from the StackSet. This tears down the CloudFormation stack in each region. Once the stack instances are removed, you can delete the stack set.


## Note

On termination, the CloudFormation custom resource in each stack attempts to delete the DNS validation CNAME, which is identical for all regions. Certificates are also deleted on termination of a stack.


