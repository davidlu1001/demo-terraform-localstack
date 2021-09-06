# demo-terraform-localstack

This repository is a Demo project for [Terraform](https://www.terraform.io/) using [Localstack](https://github.com/localstack/localstack) to simulate AWS. And use `GNU Make` to automate the Terraform workflow.

The backend is configured to store tfstate in local S3 bucket and to store tfstate lock in local DynamoDB, both running in a Localstack docker container.

## First steps

Follow the next steps to create initial configuration and test if everything is setup correctly.

### Install necessary software

To use this local setup you will need the following software available in your machine:

- docker
- docker-compose
- tfswitch
- terraform cli
- awscli

### Create docker network (for aws-cli container)

```
docker network create localstack
```

### Add network in docker-compose.yml

```
networks:
  default:
    external:
      name: "localstack"
```

### Bring up localstack container

```
make up
```

### Check localstack health status

```
make health

{
  "services": {
    "dynamodb": "running",
    "dynamodbstreams": "running",
    "kinesis": "running",
    "lambda": "running",
    "logs": "running",
    "s3": "running",
    "cloudwatch": "running"
  },
  "features": {
    "persistence": "disabled",
    "initScripts": "initialized"
  }
}
```

### Install aws-cli v2 (container version)

```
# Run AWS CLI v2 docker container
> docker run --network localstack --rm -it amazon/aws-cli --endpoint-url=http://localstack:4566 <COMMAND>

# Add alias if use AWS CLI v2 from a docker container often
alias laws='docker run --network localstack -it -v ~/.aws:/root/.aws -e LOCALSTACK_HOSTNAME=localstack amazon/aws-cli --endpoint-url=http://localstack:4566'

# Add to ~/.zshrc or ~/.bashrc
> echo "alias laws='docker run --network localstack -it -v ~/.aws:/root/.aws -e LOCALSTACK_HOSTNAME=localstack amazon/aws-cli --endpoint-url=http://localstack:4566'" >> ~/.zshrc

> source ~/.zshrc
```

### Configure AWSCLI

Create a configuration for AWS with dummy creadentials.
The only important information to localstack is the region.
Credentials validation is actually disabled.

```
aws configure
```

Or can create aws config files directly: `~/.aws/config` and `~/.aws/credentials`

```
cat ~/.aws/config
[default]
cli_pager=
output=json
region=ap-southeast-2

cat ~/.aws/credentials-localstack
[default]
aws_access_key_id=test
aws_secret_access_key=test
```

### Test AWS CLI

```
> laws lambda list-functions
{
    "Functions": []
}
```

### Install tfswitch / terraform

```
# Recommend to use tfswitch

# MacOS
> brew install warrensbox/tap/tfswitch

# Linux
> curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash

> tfswitch -l
Use the arrow keys to navigate: ↓ ↑ → ←
? Select Terraform version:
  ▸ 0.12.31 *recent
    1.0.5 *recent

> terraform -v
Terraform v1.0.5
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v3.55.0
```

### Create s3 state bucket and DynamoDB table

```
make plan
make apply
```

#### Check if s3 bucket / dynamodb table were created correctly

```
> laws s3 ls

2021-09-05 10:23:23 terraform-state

> laws dynamodb list-tables

{
    "TableNames": [
        "terraformlock"
    ]
}
```
