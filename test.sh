#!/bin/bash

STACK_SET_NAME=test-0

# Set the account id this is going to run in
ACCOUNT_ID=

# Set the hosted zone - do not include a period at the end
HOSTED_ZONE=

# The id for the hosted zone above
HOSTED_ZONE_ID=

# The EC2 key pair/ssh key that has the same name in each region
KEY_NAME=

ENV=dev

# This is used for testing the stack in a single region
# aws cloudformation create-stack \
#   --stack-name $STACK_SET_NAME \
#   --template-body file://stack-set.cfn.yml \
#   --capabilities CAPABILITY_NAMED_IAM \
#    --parameters \
#   ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE \
#   ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
#   ParameterKey=Environment,ParameterValue=$ENV \
#   ParameterKey=KeyName,ParameterValue=$KEY_NAME

# Create the StackSet
aws cloudformation create-stack-set \
  --stack-set-name $STACK_SET_NAME \
  --template-body file://stack-set.cfn.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
  ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE \
  ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
  ParameterKey=Environment,ParameterValue=$ENV \
  ParameterKey=KeyName,ParameterValue=$KEY_NAME

# Launch the Stack Instances in the defined region
aws cloudformation create-stack-instances \
  --stack-set-name $STACK_SET_NAME \
  --accounts $ACCOUNT_ID \
  --regions us-east-2 us-east-1 us-west-2

