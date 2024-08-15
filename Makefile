PROFILE := default
REGION := ap-northeast-1
BUCKET := terraform-state
SCHEDULE := "cron(0 10 ? * MON *)"

LAMBDAEXTENSION := go/data/extensions/AWSParametersAndSecretsLambdaExtension
AWS_DIR := $(shell echo $(HOME)/.aws)
GO_DIR := $(shell pwd)/go
TERRAFORM_DIR := $(shell pwd)/terraform
REGISTRYID := $(shell aws ecr describe-registry --query registryId --output text --region $(REGION) --profile $(PROFILE))

all: apply

.PHONY: extension
extension:
ifeq ("$(wildcard $(LAMBDAEXTENSION))", "")
	@curl -ss -o layer.zip `aws lambda get-layer-version-by-arn --arn arn:aws:lambda:ap-northeast-1:133490724326:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11 --query 'Content.Location' --output text` && unzip -d go/data/ layer.zip && rm layer.zip
else
	@echo "Lambda extension already exists"
endif

.PHONY: build-go
build-go: extension
	@docker build --platform=linux/amd64 --build-arg REGION=$(REGION) go -t golings-tool

.PHONY: build-terraform
build-terraform:
	@docker build terraform --build-arg BUCKET=$(BUCKET) --build-arg PROFILE=$(PROFILE) --build-arg REGION=$(REGION) --build-arg SCHEDULE=$(SCHEDULE) -t golings-tool-terraform

.PHONY: init
init: build-terraform
	echo "profile = \"$(PROFILE)\"\nregion  = \"$(REGION)\"\nbucket  = \"$(BUCKET)\"" > terraform/dev/config.tfbackend
	@docker run --rm --mount type=bind,source=$(AWS_DIR),destination=/home/terraform/.aws,readonly --mount type=bind,source=$(TERRAFORM_DIR),destination=/terraform golings-tool-terraform:latest -chdir=dev init -backend-config config.tfbackend

.PHONY: plan
plan: init
	@docker run --rm --mount type=bind,source=$(AWS_DIR),destination=/home/terraform/.aws,readonly --mount type=bind,source=$(TERRAFORM_DIR),destination=/terraform,readonly golings-tool-terraform:latest -chdir=dev plan

.PHONY: ecr
ecr: init
	@docker run --rm --mount type=bind,source=$(AWS_DIR),destination=/home/terraform/.aws,readonly --mount type=bind,source=$(TERRAFORM_DIR),destination=/terraform golings-tool-terraform:latest -chdir=dev apply -target aws_ecr_repository.main -auto-approve

.PHONY: push
push: build-go ecr
	@aws ecr get-login-password --region $(REGION) --profile $(PROFILE) | docker login --username AWS --password-stdin $(REGISTRYID).dkr.ecr.$(REGION).amazonaws.com
	@docker tag golings-tool:latest $(REGISTRYID).dkr.ecr.$(REGION).amazonaws.com/golings-tool:latest
	@docker push $(REGISTRYID).dkr.ecr.$(REGION).amazonaws.com/golings-tool:latest

.PHONY: apply
apply: push
	@docker run --rm --mount type=bind,source=$(AWS_DIR),destination=/home/terraform/.aws,readonly --mount type=bind,source=$(TERRAFORM_DIR),destination=/terraform golings-tool-terraform:latest -chdir=dev apply -auto-approve

.PHONY: clean
clean: init
	@docker run --rm --mount type=bind,source=$(AWS_DIR),destination=/home/terraform/.aws,readonly --mount type=bind,source=$(TERRAFORM_DIR),destination=/terraform golings-tool-terraform:latest -chdir=dev destroy -auto-approve
