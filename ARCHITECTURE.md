# Architecture

## Overview

This project uses AWS as the target cloud and ECS Fargate for container hosting. ECS Fargate is the preferred choice for this assignment because it reduces operational burden, aligns with the requirement to keep the platform managed, and makes the deployment path straightforward for a sample application. EKS and EC2 would add unnecessary control-plane and node-management complexity for a short assessment.

## Assumptions

- The application is a containerized Node.js 24 service listening on port 3000.
- The repo includes or will include a single web application container image built on Node 24.
- Terraform will be used for the core AWS infrastructure, while GitHub Actions handles CI/CD.
- Remote state is bootstrapped manually before initial apply because Terraform cannot create the S3 backend and DynamoDB lock table itself in a fresh account.
- The repository defaults to a local backend for immediate local validation in this workspace; the S3 backend remains available as a documented switch for shared AWS deployment.

## Target architecture

- VPC with public and private subnets across at least 2 availability zones.
- Public subnets host the ALB and NAT gateway layer.
- Private subnets host the ECS tasks and RDS PostgreSQL instance.
- Security groups enforce least privilege at every tier.
- ECS Fargate runs the application tasks behind an ALB.
- RDS PostgreSQL sits in private subnets with optional multi-AZ mode.
- CloudWatch is used for observability, including logs, alarms, and dashboards.
- GitHub Actions runs linting, tests, image build, image scanning, and deployment promotions.

## Folder structure

The repository is organized as follows:

```text
.
├── ARCHITECTURE.md
├── README.md
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── backend.tf
│   └── modules/
│       ├── network/
│       ├── compute/
│       ├── database/
│       ├── security/
│       └── loadbalancer/
├── .github/workflows/
│   ├── pr-checks.yml
│   └── build-and-deploy-production.yml
├── monitoring/
│   ├── dashboards/
│   └── alerts/
├── app/                 # sample app for proof-of-pipeline
├── docs/
│   ├── security.md
│   ├── cost-optimization.md
│   └── backup-strategy.md
└── .env.example
```

## Out-of-scope or explicit notes

- A real AWS account, domain name, and Slack webhook are intentionally represented as variables/placeholders.
- Secrets are not hardcoded; they are expected to be supplied via GitHub Actions secrets, Terraform variables, or AWS Secrets Manager.
- If a specific app repo or Dockerfile is later provided, this design can be adapted with minimal changes.

## Security and resilience notes

- ALB is internet-facing on ports 80 and 443.
- ECS tasks are only reachable from the ALB.
- RDS accepts queries only from the ECS security group.
- CloudWatch retention is configurable and defaults to a sensible value.
- Automated backups and retention rules are documented for disaster recovery.

## Alternative choices

- When the application needs more advanced Kubernetes scheduling or custom networking, EKS may be justified later; for this assignment, ECS Fargate is the correct default and simpler operational model.
