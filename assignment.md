# Project: Cloud Infrastructure, CI/CD, Monitoring & Documentation

## Context for Code

You are implementing a complete DevOps assignment end-to-end in this repository. Work
incrementally through the phases below **in order**, since later phases depend on
resources/outputs from earlier ones (e.g., CI/CD needs the registry and cluster/instance
names from Terraform; monitoring needs the app and DB already deployed).

Before writing code:

1. Propose the target architecture in a short `ARCHITECTURE.md` (cloud = AWS, compute =
   ECS Fargate unless you have a strong reason to prefer EKS/EC2 — state the reason if you
   deviate) and confirm folder structure below.
2. Create the folder structure, then implement phase by phase.
3. After each phase, run `terraform validate` / `terraform plan` (or the equivalent linter
   for that phase) and fix errors before moving on — don't wait until the end to validate.
4. Commit after each completed phase with a clear commit message.
5. Do not invent secrets, account IDs, or hostnames — use variables/placeholders and
   document what the user must supply in `.env.example` / `terraform.tfvars.example`.

## Target Repo Structure

```
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
├── app/                 # sample app (only if none exists) to prove the pipeline works
└── docs/
    ├── security.md
    ├── cost-optimization.md
    └── backup-strategy.md
```

---

## Part 1 — Infrastructure Provisioning (Terraform, AWS)

- [ ] VPC with public + private subnets across at least 2 AZs, NAT gateway(s), route tables
- [ ] Compute: ECS Fargate service (preferred) behind an ALB — or justify EC2/EKS instead
- [ ] RDS PostgreSQL in private subnets, multi-AZ optional flag via variable
- [ ] Security groups: ALB (80/443 from internet), app (only from ALB SG), RDS (only from
      app SG on 5432) — least privilege, no 0.0.0.0/0 on DB or app tiers
- [ ] Application Load Balancer with target group + health checks for the frontend
- [ ] `variables.tf` for: region, environment, instance sizes, DB engine version, DB
      storage, min/max app instance count, project/name prefix, tags
- [ ] Remote state: S3 backend + DynamoDB lock table (document the bootstrap steps since
      this backend can't provision itself)
- [ ] `outputs.tf`: VPC ID, subnet IDs, ALB DNS name, RDS endpoint (marked sensitive),
      ECS cluster/service name, security group IDs

## Part 2 — Deployment Automation (GitHub Actions)

- [ ] `pr-checks.yml`: triggered on PR — run unit + integration tests, lint, `terraform
validate`/`plan` on infra changes
- [ ] `build-and-deploy-production.yml`: triggered on merge to `main` — build Docker image,
      scan image (Trivy or `docker scout`) and dependencies (`npm audit`/`pip-audit`/
      `snyk`, whichever fits the app), push to ECR, deploy to production (ECS service update
      or equivalent)
- [ ] Failure notifications to Slack (webhook) and/or email on any job failure
- [ ] Store all credentials as GitHub Actions secrets — never hardcode

## Part 3 — Monitoring and Logging

- [ ] Infra metrics: CPU, memory, disk (CloudWatch Container Insights / EC2 metrics)
- [ ] App metrics: request rate, error rate, latency (CloudWatch custom metrics or
      embedded metrics format from the app; API Gateway/ALB metrics count too)
- [ ] DB metrics: CPU, connections, storage, read/write latency (RDS CloudWatch metrics)
- [ ] Centralized logging: app logs + system logs + ALB access logs all shipped to
      CloudWatch Logs (or ELK/Loki if you prefer — justify in ARCHITECTURE.md), with log
      groups per component and a sane retention policy set via Terraform
- [ ] At least 2 dashboards: (1) infra/app health overview, (2) DB performance — build as
      code (CloudWatch dashboard JSON via Terraform, or Grafana JSON provisioned as code)
      and store under `monitoring/dashboards/`
- [ ] Basic alerting: at least CPU/error-rate/DB-connection thresholds with SNS or Slack
      notification

## Part 4 — Documentation and Best Practices

- [ ] `README.md` covering: prerequisites, how to bootstrap remote state, how to run
      `terraform init/plan/apply`, how to trigger deploys, environment variables needed,
      architecture diagram or description, security considerations, cost optimization
      measures taken (right-sizing, autoscaling, storage lifecycle, Fargate Spot, etc.)
- [ ] Implement **at least one** of:
  - Secret management (AWS Secrets Manager or SSM Parameter Store, referenced from
    Terraform/ECS task definitions — not plaintext env vars)
  - Backup strategy (RDS automated backups + snapshot policy, documented RPO/RTO in
    `docs/backup-strategy.md`)
  - (Bonus: do both)

---

## Acceptance Criteria

- `terraform plan` runs clean against the module structure with example tfvars
- All secrets/credentials are referenced via variables, GitHub secrets, or a secrets
  manager — grep the repo for hardcoded keys before finishing
- CI pipeline YAML is syntactically valid and each job's purpose is documented with
  comments
- README is sufficient for a new engineer to stand up the production environment from scratch
- Every checkbox above is either implemented or explicitly noted as out-of-scope with a
  reason in ARCHITECTURE.md

## Working Notes for Code

- Ask me for AWS account details, Slack webhook, and any existing app repo/Dockerfile
  only if they're genuinely required to proceed — otherwise use placeholders and note
  them in `.env.example`.
- Prefer small, reviewable commits over one giant commit.
- Flag any assumption you make (e.g., "assuming Node.js app on port 3000") clearly in
  ARCHITECTURE.md so I can correct it early.
