#!/bin/bash
STACK_NAME=aws-hello-world
REGION=eu-central-1
EC2_INSTANCE_TYPE=t2.micro
PROFILE=helloworld
AWS_ACCOUNT_ID=`aws sts get-caller-identity --query "Account" --output text`

# Deploys static resources
echo -e "\n\n=========== Deploying setup.yml ==========="
aws cloudformation deploy \
	--region $REGION \
	--profile $CLI_PROFILE \
	--stack-name $STACK_NAME-setup \
	--template-file bucketSetup.yml \
	--no-fail-on-empty-changeset \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
	CodePipelineBucket=$CODEPIPELINE_BUCKET

# Deploy the CloudFormation template
echo -e "\n\n=========== Deploying main.yml ==========="
aws cloudformation deploy \
	--region $REGION \
	--profile $CLI_PROFILE \
	--stack-name $STACK_NAME \
	--template-file main.yml \
	--no-fail-on-empty-changeset \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
	EC2InstanceType=$EC2_INSTANCE_TYPE

# If the deploy succeeded, show the DNS name of the created instance
if [ $? -eq 0 ]; then
	aws cloudformation list-exports \
		--profile $CLI_PROFILE \
		--query "Exports[?Name=='InstanceEndpoint'].Value"
fi
