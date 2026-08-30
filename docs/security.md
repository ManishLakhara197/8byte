# Security notes

- Public ingress is limited to the application load balancer.
- The RDS instance is not publicly exposed.
- Security groups enforce least privilege by allowing only the required ports from trusted sources.
- Secrets should be supplied through AWS Secrets Manager or SSM Parameter Store and referenced by ECS task definitions.
- Container images should be scanned in CI for vulnerabilities before deployment.
- Runtime and CI pipelines target Node.js 24 to ensure compatibility with the current app image and GitHub Actions environment.
