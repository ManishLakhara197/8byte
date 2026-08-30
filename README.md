# Cloud Infrastructure, CI/CD, Monitoring & Documentation

This repository implements a reference AWS DevOps stack using Terraform, ECS Fargate, RDS PostgreSQL, ALB, CloudWatch, and GitHub Actions.

## Architecture summary

See [ARCHITECTURE.md](ARCHITECTURE.md) for the design rationale and assumptions.

## Prerequisites

- AWS account with IAM permissions for VPC, ECS, ECR, ALB, RDS, CloudWatch, IAM, and S3/DynamoDB.
- Node.js 24+
- Terraform 1.5+
- Docker
- GitHub repository with Actions enabled
- AWS CLI configured locally
- Optional: domain / TLS certificate if you want 443 termination

## Bootstrap remote state

The repository defaults to a local Terraform backend so it can run immediately in a fresh environment. For a shared AWS environment, bootstrap the remote backend manually before switching to the S3 configuration in [infra/backend.tf](infra/backend.tf).

```bash
aws s3api create-bucket --bucket <terraform-state-bucket> --region us-east-1
aws s3api put-bucket-versioning --bucket <terraform-state-bucket> --versioning-configuration Status=Enabled
aws dynamodb create-table \
  --table-name <lock-table-name> \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

Then uncomment the `backend "s3"` block in [infra/backend.tf](infra/backend.tf) and run:

```bash
terraform init -reconfigure
```

## Environment variables and example files

Copy the example files and fill in your values.

```bash
cp .env.example .env
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

Do not commit secrets. Use placeholders and GitHub repository secrets instead.

## Standard Terraform workflow

```bash
cd infra
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## GitHub Actions workflow

- Pull requests run lint, tests, and validation.
- Merges to `main` trigger the production deployment workflow.
- The production deployment uses the GitHub Environment named `production`.

## Security considerations

- Secrets are not stored in plaintext in the repo.
- Security groups are restricted by source and port.
- RDS is placed in private subnets.
- Only the ALB has public ingress.
- The ECS task definition should reference SSM or Secrets Manager instead of literal environment secrets.

## Cost optimization measures

- Use autoscaling for ECS tasks.
- Right-size instance and database classes.
- Keep log retention reasonable.
- Use private subnets and minimize NAT traffic.
- Consider Fargate Spot or reserved capacity where workload profile allows.

## Documentation

Additional support docs can be found in:

- [docs/implementation.md](docs/implementation.md)
- [docs/backup-strategy.md](docs/backup-strategy.md)
- [docs/security.md](docs/security.md)
- [docs/cost-optimization.md](docs/cost-optimization.md)
