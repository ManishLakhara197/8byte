# Cost optimization

- Use Fargate autoscaling to match demand.
- Keep ECS and database instance classes right-sized.
- Set CloudWatch log retention to a reasonable duration.
- Keep backups and snapshots limited to the required retention window.
- Monitor ALB, RDS, and ECS usage to reduce unnecessary over-provisioning.
