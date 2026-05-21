# Phase 2  AWS Cost Estimation

This document guides configuring the AWS Pricing Calculator and provides an estimated monthly cost table for the Phase 1 application assumptions.

## Recommended AWS regions

- Primary recommendation: `US East (N. Virginia),us-east-1` (broadest service coverage, typically lowest prices).
- Alternate regions: `US West (Oregon)`, `EU (Ireland)` for EU customers.

## Services to include in the AWS Pricing Calculator

- EC2 (Linux)  App/Web servers (use T3/T4g family for burstable workloads)
- RDS for PostgreSQL (Multi-AZ)  Managed DB
- ElastiCache (Redis)  Managed cache
- S3 Standard  Object storage (500 GB assumed)
- Data Transfer Out  2 TB/month outbound
- Application Load Balancer (ALB)
- Backup / Snapshot storage (RDS snapshots beyond free backup allotment)

---

## Step-by-step calculator configuration

1. Open the AWS Pricing Calculator: <https://calculator.aws/>
2. Add an "Amazon EC2" estimate
   - Region: `us-east-1`
   - Usage: Linux
   - Instance type: `t3.medium` (2 vCPU, 4 GB) or `t4g.medium` for Graviton (if compatible)
   - Quantity: set to baseline 2; add autoscaling note and estimate average usage 3 instances
   - Hours per month: 730
   - Storage: 30 GB EBS gp3 per instance (adjust if using AMIs or larger disks)
   - Network: assume internal traffic minimal; external traffic is modeled separately

3. Add an "Amazon RDS for PostgreSQL" estimate
   - Region: `us-east-1`
   - DB instance class: choose equivalent to 2 vCPU / 8 GB (e.g., `db.t3.large` or `db.t4g.large`)
   - Multi-AZ deployment: **Enable**
   - Storage: 100 GB General Purpose (gp3)
   - Backup retention: 30 days (set backup storage to estimate snapshot costs)

4. Add "ElastiCache (Redis)"
   - Region: `us-east-1`
   - Node type: small (1 vCPU / 2 GB)  pick a `cache.t3.small` equivalent
   - Quantity: 1; Multi-AZ optional for high availability (adds cost)

5. Add "Amazon S3"
   - Region: `US East (N. Virginia)`
   - Storage class: Standard
   - Storage amount: 500 GB
   - Requests: estimate monthly PUT/GET if needed (small incremental cost)

6. Add "Data Transfer"
   - Egress to Internet: 2,048 GB / month (2 TB)
   - Ingress: typically free (no cost entry required)

7. Add "Application Load Balancer"
   - Region: `us-east-1`
   - Specify an ALB with baseline hours (24x7) and estimated LCUs based on concurrent connections and new connections/sec. For small apps, a minimal LCU estimate is fine.

8. Add "Backup Storage" (if you want to account separate snapshot storage)
   - Estimate additional snapshot storage: 100 GB (monthly average retained)

9. Review and export the estimate CSV or PDF and capture screenshots of each service configuration and the final estimate summary.

---

## Estimated monthly pricing (approximate; USE calculator for precise numbers)

Estimates below are conservative, rounded to the nearest dollar, and based on `us-east-1` public pricing approximations as of May 2026. These are examples  run the AWS Pricing Calculator for exact numbers.

| Item | Units / Notes | Est. monthly cost (USD) |
|---|---:|---:|
| EC2 app servers (t3.medium) | avg 3 instances × 730 hrs × ~$0.0416/hr | $91 |
| RDS PostgreSQL (db.t3.large) Multi-AZ | 1 primary + standby  db instance ~$0.10/hr | $150 |
| RDS storage (100 GB gp3) | $0.08 / GB-month | $8 |
| RDS automated backups / snapshots | 100 GB snapshot budget | $10 |
| ElastiCache Redis (small) | 1 node | $20 |
| S3 Standard storage | 500 GB × $0.023/GB | $12 |
| Data transfer out (Internet) | 2,048 GB × $0.09/GB | $185 |
| Application Load Balancer (ALB) | hourly + LCU estimate | $30 |
| Monitoring & logging (CloudWatch) | metrics + logs small usage | $10 |
| Misc (DNS, NAT gateway small usage) | estimate buffer | $20 |
| **Estimated monthly total** |  | **$536** |

Notes:

- EC2 cost varies by instance family; switching to Graviton (`t4g`) can reduce compute cost ~20–40%.
- RDS Multi-AZ roughly doubles the compute portion (standby charged similarly); actual pricing depends on instance type chosen.
- Data transfer is one of the largest cost drivers; adding CloudFront CDN can reduce egress costs for static assets.

## Major AWS cost drivers (explanation)

- Data transfer (egress): Internet egress is charged per GB and adds up quickly at TB scale.
- Managed database: RDS Multi-AZ instance hours and storage are constant monthly costs.
- Compute scale: EC2 autoscaling during peaks increases cost; choose instance family carefully.
- Load balancing & LCUs: ALB charges include hourly and usage-based LCU costs  heavy short-lived connections increase cost.
- Storage requests/tiers: S3 requests are cheap, but lifecycle to Infrequent Access or Glacier can reduce storage cost.

## AWS cost optimization recommendations

- Use Graviton-based instances (`t4g`) where supported to reduce instance cost.
- Use AWS Savings Plans or Reserved Instances for predictable steady-state workloads (commit 1–3 years).
- Offload static assets to CloudFront to reduce egress costs.
- Use lifecycle policies to move older objects to S3 IA / Glacier.
- Right-size RDS and consider serverless or Aurora if the workload fits.
