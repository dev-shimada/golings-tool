# golings-tool go

## Getting Started
### Get Lambda Extensions
AWSParametersandSecretsLambdaExtension
```bash
curl -o layer.zip $(aws lambda get-layer-version-by-arn --arn arn:aws:lambda:ap-northeast-1:133490724326:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11 --query 'Content.Location' --output text)
unzip -d data/ layer.zip
rm layer.zip
```

### Devcontainer
```bash
devconteiner open .
```

### Test
```bash
go test ./...
```

### Check
```bash
go vet ./...
staticcheck ./...
```

## build
```bash
docker build --platform=linux/amd64 . -t golings-tool
```
