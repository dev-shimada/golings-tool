# golings-tool terraform

## Getting Started
### Devcontainer
```bash
devconteiner open .
```

### Terraform init
Create the S3 bucket in advance.
```bash
cd dev
terraform init -backend-config config.tfbackend
```

### Check
```bash
cd dev
terraform fmt -recursive
terraform validate
```

## Plan
```bash
cd dev
terraform plan
```

## Apply
```bash
cd dev
terraform apply
```
