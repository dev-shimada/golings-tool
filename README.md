# golings-tool
Create a tool on AWS that sends a notification through golings to Slack every Monday at 10 AM.

## Required
- aws cli
- docker
- make
- curl

## Getting Started
### Set webhook url
```bash
aws ssm put-parameter --name "/golings-tool/WEBHOOK_URL" --value "your slack webhook url" --type "SecureString"
```

### Create terraform backend S3 bucket
Create an S3 bucket in your AWS environment to use as a terraform backend.

### Edit Makefile
- PROFILE
- REGION
- BUCKET
- SCHEDULE

### Deploy
```bash
make
```

## Clean up
```bash
make clean
```

## Awsome projects
- mauricioabreu golings: https://github.com/mauricioabreu/golings
- tenntenn goplayground: https://github.com/tenntenn/goplayground
