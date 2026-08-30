# Backup Strategy

## RDS automated backups

- Enable automated backups for PostgreSQL with a 7-day retention window.
- Use snapshots before major schema changes or releases.

## Recovery objectives

- Recovery point objective (RPO): up to 24 hours depending on backup cadence and replication configuration.
- Recovery time objective (RTO): targeted at under 1 hour for a single-db restore in a staging or low-volume environment.

## Operational guidance

- Keep a restore runbook for point-in-time recovery or snapshot restoration.
- Validate restore drills periodically.
- Keep encryption enabled for all backup data.
