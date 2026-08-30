# Implementation Guide

This guide walks through the full setup for this repository end-to-end: Slack notifications, GitHub repository configuration, environment and secret management, AWS account setup, Terraform bootstrapping, deployment automation, and validation.

This project already contains:

- Terraform infrastructure under `infra/`
- GitHub Actions workflows under `.github/workflows/`
- Monitoring definitions under `monitoring/`
- App code under `app/`
- Documentation under `docs/`

The intended architecture is AWS + ECS Fargate + ALB + RDS PostgreSQL + CloudWatch + GitHub Actions. The repo is already set up around that pattern.

---

## 1. Prerequisites

Before you start, make sure you have the following installed locally:

- Git
- AWS CLI v2
- Terraform 1.5+
- Docker
- Node.js 24+
- A GitHub account with repository admin access
- A Slack workspace with permission to create incoming webhooks

You should also have an AWS account with permissions for:

- IAM
- VPC
- ECS
- ECR
- ALB
- RDS
- CloudWatch
- S3
- DynamoDB
- Secrets Manager

For a fresh account, use a user or role with admin-level access for the initial bootstrap, then reduce permissions later.

---

## 2. Project Structure Summary

This repo is already aligned with the intended setup:

- `infra/` contains Terraform modules for network, security, load balancer, database, and compute
- `infra/backend.tf` uses a local backend by default; remote S3 backend is documented as the shared deployment option
- `.github/workflows/pr-checks.yml` runs PR validation
- `.github/workflows/build-and-deploy-staging.yml` builds and deploys the application
- `monitoring/alerts/cloudwatch-alerts.tf` and `monitoring/dashboards/*.json` provide alerting and dashboards
- `.env.example` and `infra/terraform.tfvars.example` show the expected placeholder values

---

## 3. Slack Setup

Slack notifications are used for failed CI/CD jobs.

### Step 3.1: Create an incoming webhook

1. Open Slack and go to your workspace.
2. Open the Slack App Directory and search for `Incoming Webhooks`.
3. Add the app to the workspace.
4. Choose the channel where pipeline alerts should post.
5. Copy the generated webhook URL.

Example format:

```text
https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```

### Step 3.2: Save it as a secret

Do not put the webhook URL directly into code. Store it in GitHub secrets later.

---

## 4. GitHub Repository Setup

### Step 4.1: Create or import the repo

1. Create a GitHub repository for this project.
2. Push the current code to the `main` branch.
3. Enable GitHub Actions in the repository settings.
4. Confirm the default branch is `main`.

### Step 4.2: Add required branch protection

In GitHub:

1. Go to `Settings` → `Branches`
2. Add a branch protection rule for `main`
3. Enable:
   - Require a pull request before merging
   - Require status checks to pass before merging
   - Require branches to be up to date before merging
4. If you want stricter controls, also require review approvals

This matches the repo’s PR validation workflow in `.github/workflows/pr-checks.yml`.

### Step 4.3: Create the GitHub Environment

Go to `Settings` → `Environments` and create:

- `staging`

This matches the current repository workflow model, which uses the single active deployment workflow in `.github/workflows/build-and-deploy-staging.yml`.

---

## 5. GitHub Secrets and Environment Secrets

The repo references secrets like:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_ACCOUNT_ID`
- `ECR_REPOSITORY`
- `SLACK_WEBHOOK_URL`

These should be added in the repository settings under `Settings` → `Secrets and variables` → `Actions`.

### Recommended secret list

Repository secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_ACCOUNT_ID
ECR_REPOSITORY
SLACK_WEBHOOK_URL
```

Environment secrets for `staging`:

- Keep deployment-appropriate credentials there if you want environment-specific scoping
- Add the same Slack webhook if you want environment-specific notification behavior

### Important note

Never hardcode AWS keys or Slack URLs in the repo. The repo already uses placeholders in `.env.example` and `infra/terraform.tfvars.example` to guide setup.

---

## 6. Local Environment Setup

Create a local environment file for your workstation:

```bash
cp .env.example .env
```

Then edit `.env` with your actual values:

```env
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012
ECR_REPOSITORY=example-app
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/REPLACE/ME
GITHUB_TOKEN=REPLACE_WITH_GITHUB_TOKEN
```

Use this mainly for local commands and documentation. For live production use, prefer GitHub Actions secrets and AWS-managed secrets.

---

## 7. AWS Manual Setup

A fresh AWS account requires a few manual steps before Terraform can fully provision the environment.

### Step 7.1: Configure AWS CLI

```bash
aws configure
```

Or set environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Step 7.2: Verify access

```bash
aws sts get-caller-identity
```

You should see your AWS account ID and ARN.

### Step 7.3: Create the Terraform remote state bucket and lock table

This is required because the repo’s `infra/backend.tf` has a local backend by default, and the remote S3 backend must be bootstrapped manually.

#### Create the S3 bucket

```bash
aws s3api create-bucket \
  --bucket your-terraform-state-bucket \
  --region us-east-1
```

If using a region other than us-east-1, use the appropriate bucket creation pattern for that region.

#### Enable versioning

```bash
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled
```

#### Enable default encryption

```bash
aws s3api put-bucket-encryption \
  --bucket your-terraform-state-bucket \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

#### Create the DynamoDB lock table

```bash
aws dynamodb create-table \
  --table-name your-terraform-lock-table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### Step 7.4: Create the ECR repository

The CI workflow assumes an ECR repository exists.

```bash
aws ecr create-repository \
  --repository-name example-app \
  --region us-east-1
```

If you want a different name, align it with the value in GitHub secrets and your `terraform.tfvars` file.

### Step 7.5: Optional IAM strategy

For a practical setup, create a dedicated IAM user or GitHub OIDC role for CI/CD.

Best practice is to prefer GitHub OIDC over long-lived AWS access keys. However, because this repo currently uses `aws-actions/configure-aws-credentials` with access keys, you can start with IAM user credentials and later migrate to OIDC.

Suggested minimal permissions for the bootstrap user:

- VPC permissions
- ECS permissions
- ECR permissions
- ALB permissions
- RDS permissions
- IAM permissions for roles and policies
- CloudWatch and logs permissions
- S3 and DynamoDB permissions for backend state

---

## 8. Terraform Setup

The Terraform configuration is under `infra/` and includes:

- `providers.tf`
- `backend.tf`
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `modules/*`

### Step 8.1: Review and configure tfvars

Copy the example file:

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

Edit `infra/terraform.tfvars` with your actual values:

```hcl
region = "us-east-1"
environment = "staging"
project_name = "example"
name_prefix = "eightbytes"
availability_zones = ["us-east-1a", "us-east-1b"]
app_cpu = 256
app_memory = 512
db_instance_class = "db.t3.micro"
db_allocated_storage = 20
db_engine_version = "16.3"
db_password = "ChangeMePassword123!"
min_capacity = 1
max_capacity = 2
db_multi_az = false
vpc_cidr = "10.10.0.0/16"
public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
app_port = 3000
container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-app:latest"
aws_account_id = "123456789012"
```

Important:

- `db_password` should be moved to a secure secret manager in production
- `container_image` should point to the ECR repository you created
- Replace placeholder values with your account ID and AWS region

### Step 8.2: Initialize Terraform

From the `infra` directory:

```bash
cd infra
terraform init
```

If using the remote S3 backend, do:

```bash
terraform init -reconfigure
```

### Step 8.3: Validate the module

```bash
terraform validate
```

### Step 8.4: Create a plan

```bash
terraform plan -var-file="terraform.tfvars"
```

### Step 8.5: Apply the configuration

```bash
terraform apply -var-file="terraform.tfvars"
```

Review the output carefully before confirming.

---

## 9. Terraform Remote State

The repo uses a local backend by default for easy setup in a local workspace. For shared team usage, switch to S3 backend state.

In `infra/backend.tf`, the current default is:

```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

To switch to the S3 remote backend, uncomment the `backend "s3"` block and set the correct bucket name and DynamoDB lock table name:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "eightbytes/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "your-terraform-lock-table"
}
```

Then run:

```bash
terraform init -reconfigure
```

---

## 10. GitHub Actions Setup

The repo already includes pipeline files:

- `.github/workflows/pr-checks.yml`
- `.github/workflows/build-and-deploy-staging.yml`

### PR checks

The PR workflow does the following:

- checks out the code
- sets up Node.js
- installs app dependencies
- runs `npm test`
- installs Terraform
- runs `terraform init -backend=false`
- runs `terraform validate`
- runs `terraform plan`

### Staging deployment

The staging workflow:

- checks out the code
- configures AWS credentials
- logs into ECR
- builds the Docker image from `app/`
- scans the image with Trivy
- pushes it to ECR
- deploys the update to ECS staging
- notifies Slack on failure

### Deployment model

The repository is currently configured around the two active workflows: PR validation and the single build/deploy pipeline for staging.

---

## 11. AWS ECR and ECS Deployment Flow

### Step 11.1: Ensure the repository is built correctly

From the repo root:

```bash
docker build -t your-account-id.dkr.ecr.us-east-1.amazonaws.com/example-app:latest ./app
```

### Step 11.2: Authenticate Docker to ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### Step 11.3: Push the image

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/example-app:latest
```

### Step 11.4: Update the Terraform image reference

If the image tag changes, update `container_image` in `infra/terraform.tfvars` so ECS points to the right image.

---

## 12. Secrets Management Best Practice

This repo already documents the expected pattern: do not put secrets directly into source code.

Recommended production approach:

- Store DB credentials in AWS Secrets Manager
- Inject them into ECS tasks via task definition variables or a secrets reference
- Keep GitHub Actions secrets for CI/CD authentication
- Use environment-specific secrets for staging and production if needed

The current project is structured to allow that but still works with placeholders during local setup.

---

## 13. Monitoring and Alerting Setup

The repo already includes:

- `monitoring/alerts/cloudwatch-alerts.tf`
- `monitoring/dashboards/infra-overview.json`
- `monitoring/dashboards/db-performance.json`

### After Terraform apply

1. Check whether the CloudWatch alarms were created
2. Verify ECS metrics are visible in CloudWatch
3. Verify ALB and RDS metrics are collected
4. Check log groups under `/ecs/...`
5. Create the CloudWatch dashboards defined in `monitoring/dashboards/`

Useful checks:

```bash
aws logs describe-log-groups --region us-east-1
aws cloudwatch describe-alarms --region us-east-1
aws cloudwatch list-dashboards --region us-east-1
```

### Create the CloudWatch dashboards

Create the infrastructure overview dashboard:

```bash
aws cloudwatch put-dashboard \
  --region us-east-1 \
  --dashboard-name eightbytes-infra-overview \
  --dashboard-body file://monitoring/dashboards/infra-overview.json
```

Create the database performance dashboard:

```bash
aws cloudwatch put-dashboard \
  --region us-east-1 \
  --dashboard-name eightbytes-db-performance \
  --dashboard-body file://monitoring/dashboards/db-performance.json
```

> Replace the placeholder resource names in the dashboard JSON with your actual ECS cluster, ALB, and RDS instance names before creating the dashboards in AWS.

---

## 14. Validation Checklist

Before considering the environment ready, confirm all of the following:

- AWS CLI works and is configured
- Terraform init succeeds
- Terraform validate succeeds
- Terraform plan succeeds without errors
- ECR repository exists
- GitHub repo is configured with Actions enabled
- GitHub secrets are added
- GitHub environment is created
- Slack webhook URL is valid
- `infra/terraform.tfvars` points to correct account and region
- Terraform apply completes successfully
- ECS service comes up healthy
- ALB DNS is reachable
- RDS is reachable only from the app tier
- CloudWatch logs and alarms are functional

---

## 15. Common Troubleshooting

### Terraform errors

- `No valid credential sources found`: configure AWS CLI or set environment variables
- `AccessDenied`: fix IAM permissions
- `bucket already exists`: choose a unique S3 bucket name
- `database password policy`: use a compliant password string

### GitHub Actions failures

- Check if required secrets are missing in repository or environment settings
- Validate that the Slack webhook URL is correct
- Check whether the ECR repository name matches the secret value
- Ensure the branch and workflow triggers match your deployment flow

### ECS failures

- Confirm the task definition uses the correct container image
- Check the container port matches `app_port`
- Verify the security groups allow traffic from ALB to app
- Check CloudWatch logs for the failing task

### Slack not receiving alerts

- Confirm the webhook is valid and active
- Ensure the workflow runs the Slack curl step on failure
- Validate the secret value is correct in GitHub

---

## 16. Recommended Production Hardening

Once the environment is stable, consider the following:

- Move AWS credentials from long-lived access keys to GitHub OIDC
- Store database passwords in AWS Secrets Manager
- Turn on encryption at rest for sensitive data
- Restrict IAM roles to least privilege
- Use private subnets for RDS and ECS tasks
- Add CloudWatch alarm actions through SNS and Slack
- Add lifecycle rules for logs and backups
- Enable multi-AZ for the database in production

---

## 17. Final Setup Sequence

If you want the simplest order to follow, use this sequence:

1. Create the Slack incoming webhook
2. Create the GitHub repo and enable Actions
3. Add GitHub secrets
4. Create the GitHub environment for staging
5. Configure AWS CLI and IAM access
6. Create the Terraform backend resources (S3 + DynamoDB)
7. Create the ECR repo
8. Copy `.env.example` and `infra/terraform.tfvars.example`
9. Fill in real values
10. Run `terraform init`, `validate`, `plan`, and `apply`
11. Verify ECS, ALB, and RDS status
12. Push a branch and confirm PR checks run
13. Merge to `main` and verify the build/deploy workflow
14. Confirm CloudWatch alerts and Slack notifications are working

---

## 18. Notes for This Repository

This repo is intentionally implemented with placeholders rather than real secrets. That is the correct pattern for a starter project and aligns with the assignment requirements.

The following files are the main places to update for your actual environment:

- `.env.example`
- `infra/terraform.tfvars.example`
- `infra/backend.tf`
- `.github/workflows/*.yml`

If you want to make this setup fully production-ready, the next step would be to replace the placeholder credentials with AWS Secrets Manager references and use GitHub OIDC instead of static access keys.
