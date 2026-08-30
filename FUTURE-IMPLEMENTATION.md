# Future Implementation Roadmap

This document captures the next-stage improvements that extend the current baseline into a more hardened production-ready platform.

## Planned improvements

### Security hardening

- Move AWS credentials from long-lived access keys to GitHub OIDC.
- Store database credentials and sensitive environment values in AWS Secrets Manager.
- Tighten IAM policies to least-privilege access.
- Keep production configuration separated from non-production settings.

### Reliability and performance

- Add autoscaling tuning for ECS services based on CPU and memory usage.
- Enable multi-AZ support for the database in production where needed.
- Improve health checks and deployment rollback strategy.
- Review log retention and backup policies against operational needs.

### Operational maturity

- Add more structured alerting and runbooks for common incidents.
- Expand dashboards with application-specific metrics.
- Add deployment approval and release gates where required.
- Standardize environment drift checks and change review practices.

## Related documents

- Approach overview: [APPROACH.md](APPROACH.md)
- Implementation guide: [implementation.md](implementation.md)
- Architecture design: [ARCHITECTURE.md](ARCHITECTURE.md)

## Summary

The current state provides a solid baseline. The future roadmap focuses on increasing security, operational confidence, and scale-readiness without changing the overall delivery model.
