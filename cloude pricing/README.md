# Cloud Cost Comparison Report

## Cloud Cost Comparison  AWS vs Azure

This repository contains a step by step cloud cost comparison project between Amazon Web Services and Microsoft Azure, scoped to a small SaaS invoicing and payments application.

## Project objectives

- Provide end to end cost estimates for AWS and Azure for a realistic small business SaaS workload.
- Compare Linux and Windows VM scenarios and quantify the impact of Azure Hybrid Benefit.
- Analyze networking, backup, and storage costs and highlight major cost drivers.
- Model 1- and 3-year commitment savings and produce visual charts for decision-making.

## What you'll find in this folder

- `PHASE2_AWS.md`  AWS Pricing Calculator setup and estimates
- `PHASE3_AZURE.md`  Azure Pricing Calculator setup and estimates
- `PHASE4_NETWORKING.md`  Networking cost analysis and tiered examples
- `PHASE5_DISCOUNTS.md`  Discount and savings analysis
- `PHASE6_COMPARISON.md`  Final comparison report and recommendations
- `aws_estimate.csv`, `azure_estimate.csv`, `comparison_estimates.csv`  baseline CSV estimates
- `savings_1yr.csv`, `savings_3yr.csv`  modeled savings for commitments
- `summary.txt`  300-word business justification summary

## Tools used

- AWS Pricing Calculator: <https://calculator.aws/>
- Azure Pricing Calculator: <https://azure.microsoft.com/pricing/calculator/>
- Local CSVs and generated SVG charts for quick visual comparisons

## How to use

1. Open `PHASE2_AWS.md` and `PHASE3_AZURE.md` and follow the step by step instructions to reproduce calculator inputs.
2. Inspect CSVs in this folder to reproduce charts or export to Excel.
3. Review `PHASE6_COMPARISON.md` for executive recommendations.

## Conclusion

This analysis shows that for the assumed workload, AWS and Azure have similar baseline costs for Linux workloads; Azure is more cost effective for Windows workloads when Azure Hybrid Benefit applies. Egress and managed database costs are the largest drivers. Use the provided CSVs and calculators to refine estimates for your exact region and instance SKUs.

---

## Phase 2  AWS Cost Estimation

This document guides configuring the AWS Pricing Calculator and provides an estimated monthly cost table for the application assumptions.

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
- RDS Multi AZ roughly doubles the compute portion (standby charged similarly); actual pricing depends on instance type chosen.
- Data transfer is one of the largest cost drivers; adding CloudFront CDN can reduce egress costs for static assets.

## Major AWS cost drivers (explanation)

- Data transfer (egress): Internet egress is charged per GB and adds up quickly at TB scale.
- Managed database: RDS Multi AZ instance hours and storage are constant monthly costs.
- Compute scale: EC2 autoscaling during peaks increases cost; choose instance family carefully.
- Load balancing & LCUs: ALB charges include hourly and usage-based LCU costs  heavy short-lived connections increase cost.
- Storage requests/tiers: S3 requests are cheap, but lifecycle to Infrequent Access or Glacier can reduce storage cost.

## AWS cost optimization recommendations

- Use Graviton-based instances (`t4g`) where supported to reduce instance cost.
- Use AWS Savings Plans or Reserved Instances for predictable steady state workloads (commit 1–3 years).
- Offload static assets to CloudFront to reduce egress costs.
- Use lifecycle policies to move older objects to S3 IA / Glacier.
- Right-size RDS and consider serverless or Aurora if the workload fits.

## Screenshots to capture (for documentation)

- EC2 configuration page in AWS Pricing Calculator
- RDS configuration page (showing Multi-AZ and storage)
- S3 configuration (500 GB entry)
- Data transfer configuration (2 TB egress)
- ALB configuration and LCU settings
- Final estimate summary (combined view)

---
# Phase 3  Azure Cost Estimation

This document guides using the Azure Pricing Calculator and provides example monthly estimates for both Linux and Windows VM scenarios (including Azure Hybrid Benefit).

## Recommended Azure regions

- Primary recommendation: `East US (eastus)` good service coverage and typical price competitiveness.
- Alternate regions: `West Europe (westeurope)`, `Southeast Asia` for APAC customers.

## Services to include in the Azure Pricing Calculator

- Virtual Machines (Linux VMs and Windows VMs)
- Managed Disks (Premium SSD for OS / data)
- Blob Storage (Hot tier)
- Load Balancer / Application Gateway
- Azure Backup (Recovery Services vault)
- Networking: egress (outbound) data transfer
- Optional: Azure CDN, Azure Cache for Redis, Azure Database for PostgreSQL (managed)

---

## Scenario definitions

1. Linux VM scenario (production)
   - VM size: `Standard_D2s_v3` equivalent (2 vCPU, 8 GB RAM) or `B2ms` for burstable workloads
   - Quantity: baseline 2 instances, autoscale 2-6; estimate average usage 3 instances
   - OS: Linux (no Windows licensing charge)
   - Managed disk: Premium SSD P10 (128 GB) or 30 GB OS disk as needed

2. Windows VM scenario (with Azure Hybrid Benefit)
   - VM size: `Standard_D2s_v3` equivalent (2 vCPU, 8 GB RAM)
   - Quantity: baseline 2 instances, average 3
   - OS: Windows Server  apply Azure Hybrid Benefit to reuse existing Windows Server licenses with Software Assurance or eligible subscriptions to reduce OS cost
   - Managed disk: Premium SSD P10 (128 GB)

---

## Step-by-step Azure Pricing Calculator configuration

1. Open Azure Pricing Calculator: <https://azure.microsoft.com/en-us/pricing/calculator/>
2. Add "Virtual Machines"
   - Region: `East US`
   - OS: Linux for the Linux scenario; Windows for the Windows scenario
   - VM series: `Dsv3` or `B-series` depending on workload
   - Instance count: baseline 2; set hours 730
   - Managed disk: select Premium SSD (e.g., 128 GB)
   - For Windows scenario: toggle `Azure Hybrid Benefit` (if you have eligible licenses) to reduce OS charge

3. Add "Storage Blob Storage"
   - Region: `East US`
   - Tier: Hot
   - Data: 500 GB
   - Operations: leave default (or add based on expected PUT/GET)

4. Add "Load Balancer" (or Application Gateway)
   - Choose Standard Load Balancer or Application Gateway (WAF if needed)
   - Configure hourly and data processed estimates; small apps usually have modest processing costs

5. Add "Backup" (Recovery Services vault)
   - Configure backup instances: include 1 DB + VM backups
   - Estimated protected instances: 3
   - Backup storage type: Locally redundant storage (LRS) or Geo-redundant (GRS) if required

6. Add "Data Transfer"
   - Outbound (egress): 2,048 GB / month
   - Inbound is typically free

7. Add any optional services (CDN, Redis) used in the architecture

8. Export the estimate and capture screenshots of each configuration and the final cost summary.

---

## Estimated monthly pricing (approximate use Azure Calculator for exact values)

All costs approximated for `eastus` as of May 2026 and rounded.

| Item | Units / Notes | Linux scenario (USD) | Windows w/ Hybrid Benefit (USD) |
|---|---:|---:|---:|
| VM compute (D2s_v3 equiv) | avg 3 instances × 730 hrs × ~$0.096/hr (Linux) | $210 | $260 (Windows base) |
| Azure Hybrid Benefit (OS discount) | applied to Windows scenario | N/A | -$60 (example savings) |
| Managed disks (128 GB × 3) | Premium SSD ~ $20 / disk | $60 | $60 |
| Blob storage (500 GB, Hot) | 500 GB × $0.0184/GB | $9 | $9 |
| Load Balancer / App GW | hourly + processed data | $25 | $25 |
| Backup (Recovery Services) | protect 3 instances, daily, 30d | $25 | $25 |
| Data transfer out | 2,048 GB × $0.087/GB | $178 | $178 |
| Monitoring & logs | Azure Monitor (small) | $10 | $10 |
| Misc (DNS, extra services) | buffer | $15 | $15 |
| **Estimated monthly total** |  | **$532** | **$482** |

Notes:

- Windows VMs without Azure Hybrid Benefit will be noticeably higher due to OS licensing Hybrid Benefit reduces the OS portion.
- Azure often bundles some networking efficiencies; using Azure CDN reduces egress for static content.

## Azure Hybrid Benefit

- Azure Hybrid Benefit (AHB) lets you use existing on premises Windows Server and SQL Server licenses with Software Assurance, or eligible subscriptions, to save on Azure VM OS and SQL licensing costs.
- For Windows VMs, AHB can reduce VM pricing by removing the OS license surcharge. Savings depend on VM size and region.
- Use AHB when you have active license coverage; otherwise Windows pay-as-you-go rates apply.

## Azure pricing advantages and disadvantages

Advantages:

- Strong discounts for Windows workloads via Azure Hybrid Benefit.
- First class integration for Microsoft products (Active Directory, SQL Server licensing, Windows tools).
- Transparent per minute billing and hybrid scenarios.

Disadvantages:

- Some VM families are more expensive vs AWS for equivalent CPU/memory without careful selection.
- Outbound data transfer remains a major cost driver similar to AWS.

## Cost optimization recommendations (Azure)

- Apply Azure Hybrid Benefit for Windows workloads when eligible.
- Use B series burstable VMs for low baseline CPU workloads to reduce steady state cost.
- Use Azure CDN to reduce egress costs for static assets.
- Use Reserved VM Instances (1 or 3 year) or Azure Savings Plans for compute-heavy predictable workloads.
- Use lifecycle management for Blob Storage: move to Cool/Archive for older objects.

# Phase 4 Networking Cost Analysis

This document compares networking costs for AWS and Azure for the Phase 1 application and explains multi zone, outbound, and load-balancer transfer impacts.

## Pricing components to compare

- Inter-AZ / inter-zone data transfer (between availability zones)
- Outbound internet (egress) data transfer
- Load balancer data processing and bandwidth charges
- NAT Gateway / egress gateway costs (if used)

## Key vendor behaviors (summary)

- AWS: charges for data transfer between AZs within the same region for some services (e.g., AZtoAZ traffic for EC2 across AZs often billed pe GB). Internet egress billed per GB with tiered pricing. Load balancers (ALB/NLB) charge hourly + LCU/data processed.
- Azure: charges for inter-zone or inter region traffic vary; intra region zone traffic often billed, but specifics depend on service. Outbound to internet billed per GB. Load Balancer / Application Gateway have processing and data charges.

## Inter-zone traffic pricing (typical formulas)

- AWS inter AZ transfer: Cost_interAZ = GB_transferred × rate_interAZ (e.g., $0.01–$0.02/GB depending on region)
- Azure intra-zone/zone transfer: Cost_zone = GB_transferred × rate_zone (region dependent)

Example: If app replicas sync 100 GB/day between zones: monthly = 100 × 30 = 3,000 GB. At $0.02/GB ⇒ $60/month (per-direction). Bi-directional sync doubles this.

## Outbound internet traffic

- Formula: Cost_egress = GB_egress × rate_egress
- Using our assumption 2,048 GB/month and approximate rates:
  - AWS: 2,048 × $0.09/GB ≈ $184.32
  - Azure: 2,048 × $0.087/GB ≈ $178.18

Notes: Both providers offer tiered pricing; larger volumes reduce per-GB cost. CDNs (CloudFront/Azure CDN) significantly reduce origin egress by caching static assets at edge.

## Load balancer transfer impact

- ALB / Application Gateway pricing typically includes hourly + usage (LCU) or data processed. Heavy north-south traffic passing through load balancers increases both LCU and data charges.
- For architectures with many small requests, LCU charges (connections, new connections/sec) can dominate.

Cost formula (simplified):

- Cost_ALB = hourly_rate × hours + data_GB × data_rate + LCU_units × LCU_rate

## Multi-zone architecture cost implications

- Pros: higher availability and resilience; traffic localized within zone reduces cross AZ egress if clients are zonal aware.
- Cons: increased inter zone replication/sync costs for stateful services (DB replication, shared caches), possible cross zone load balancing charges.
- Recommendation: Minimize cross-AZ chatter  use regional services (managed DB Multi-AZ is optimized) and prefer async replication where possible.

## Hidden networking costs to watch for

- NAT Gateway / egress gateway per hour and per GB charges
- Cross region replication costs (DB or object replication)
- PrivateLink / VPC endpoints data processing costs
- VPN/ExpressRoute / Direct Connect port and data fees for hybrid setups

## Scalability impact and real-world examples

- Example 1  Read replica sync: a reporting replica replicates 500 GB/month from primary. If cross AZ at $0.02/GB = $10/month  small.
- Example 2  Backup and restore: Restoring a 200 GB snapshot across regions will incur regional transfer fees; plan backup retention and location to optimize.
- Example 3  CDN impact: Offloading 1.5 TB of static assets to CDN reduces origin egress by 75%  direct egress cost savings significant.

## Networking comparison table (summary)

| Category | AWS (typical) | Azure (typical) |
|---|---:|---:|
| Inter AZ transfer | ~$0.01–$0.02/GB | region dependent, often similar |
| Outbound internet | ~$0.09/GB (first TB ranges higher) | ~$0.087/GB (varies by zone) |
| Load balancer | hourly + LCU/data | hourly + data processing (App GW) |
| NAT Gateway | per hour + per GB | similar per hour + per GB |

## Recommendations to reduce networking costs

- Use CDN for static assets; set long TTLs for infrequently changing content.
- Aggregate and batch cross-zone replication to off peak windows where possible.
- Use regional managed services to avoid custom cross AZ traffic when feasible.
- Monitor egress with cloud billing alerts and use cost allocation tags to attribute traffic to services.

---

## Tiered per-GB examples and cost table

Assumed example tiered rates (typical, region dependent):

- AWS egress tiers: 0–10 TB @ $0.090/GB; next 40 TB @ $0.085/GB; next 50 TB @ $0.070/GB
- Azure egress tiers: 0–10 TB @ $0.087/GB; next 40 TB @ $0.083/GB; next 50 TB @ $0.065/GB

Example cost calculations:

| Volume | AWS cost (approx) | Azure cost (approx) |
|---:|---:|---:|
| 2 TB (2,048 GB) | 2,048 × $0.090 = $184.32 | 2,048 × $0.087 = $178.18 |
| 20 TB (20,480 GB) | first 10 TB (10,240×0.09) + next 10 TB (10,240×0.085) = $1,792.00 | first 10 TB (10,240×0.087) + next 10 TB (10,240×0.083) = $1,740.80 |
| 100 TB (102,400 GB) | 10,240×0.09 + 40,960×0.085 + 51,200×0.07 = $7,987.20 | 10,240×0.087 + 40,960×0.083 + 51,200×0.065 = $7,618.68 |

Notes:

- These are illustrative; actual tier boundaries and rates vary by region and over time. Use provider price pages or calculators for exact quotes.
- For our baseline app (2 TB egress), egress is a dominant cost  consider CDN to reduce origin egress.

## Per-GB tiered comparison (quick guidance)

- Under ~10 TB/month: per GB prices for AWS and Azure are similar; minor differences depend on negotiated pricing or region.
- Between 10–50 TB/month: small differences in the next-tier rates begin to matter negotiate or use Savings/commitment options.
- Above 50 TB/month: consider direct peering, CDN, or negotiated enterprise discounts to materially reduce egress cost.

# Phase 5 Discount & Savings Analysis

This document compares AWS and Azure discount mechanisms and shows example savings for the Phase 1 application.

## Overview

- Commitment-based discounts reduce compute and sometimes licensing costs in exchange for 1 or 3 year commitments.
- Key AWS mechanisms: Reserved Instances (RIs) and Savings Plans.
- Key Azure mechanisms: Reserved VM Instances (RIs), Azure Savings Plans, and Azure Hybrid Benefit (AHB) for Windows/SQL Server licensing.

## AWS: Savings Plans vs Reserved Instances

- Reserved Instances (RIs): commit to specific instance family/region for 1 or 3 years. Offer up to ~30–60% savings vs on demand depending on payment option (partial/ all upfront).
- Savings Plans: commit to $/hour usage for 1 or 3 years and get flexible discounts across instance families and regions. Compute Savings Plans are more flexible than RIs.

Example (EC2 compute):

- Baseline EC2 monthly (on demand): $91 → annual $1,092
- 1-year Savings Plan ~30% savings → annual ~$764 (monthly ~$64) → monthly saving ~$27

Pros:

- Savings Plans: flexible application across instance families and regions.
- RIs: deeper discounts for specific, steady state instances.

Cons:

- Commitments require forecasting; changing architectures can undercut savings.

## Azure: Reserved Instances, Savings Plans, and Azure Hybrid Benefit

- Azure Reserved VM Instances: commit to VM types/region for 1 or 3 years; typical savings 30-55%.
- Azure Savings Plans: commit to spend for compute for 1 or 3 years  similar flexibility to AWS Savings Plans.
- Azure Hybrid Benefit (AHB): re use existing Windows Server / SQL Server licenses with Software Assurance or eligible subscriptions to remove OS licensing cost from VM pricing.

Example (Windows VM + AHB + Reserved):

- Baseline Windows monthly (on demand): $260 → annual $3,120
- Apply Azure Hybrid Benefit: $60/mo → $200/mo → annual $2,400
- Add 1-year Reserved Instance 35% discount → $1,560/yr → monthly ~$130 (total savings from on demand ~50%)

## Commitment based pricing vs Pay-as-you-go

- Pay-as-you-go: maximum flexibility, no commitment, higher unit cost.
- Commitment (1–3 year): lower unit cost, risk if usage patterns change.
- Use a mix: reserve for steady baseline, use on-demand for burst/variable traffic.

## Best use cases

- Startups with uncertain load: begin pay-as-you-go; reserve only stable baseline later.
- Enterprises with predictable steady state workloads: use RIs/Savings Plans for large savings.
- Windows heavy workloads: apply Azure Hybrid Benefit for substantial licensing savings.

## Example savings calculations (consolidated)

1) EC2 compute example

- On-demand EC2 monthly: $91
- 1-year Savings Plan (30%): $63.7 (monthly) → saves $27.3/mo → annual savings ~$327.6

1) Azure Windows VM example (from Phase 3)

- On-demand Windows monthly: $260
- With AHB: $200
- With AHB + 1-year RI (35%): $130 ← net monthly savings $130 vs on-demand (~50%)

## Pros and Cons table

| Mechanism | Pros | Cons |
|---|---|---|
| AWS Savings Plans | Flexible across families/regions | Requires commit; still bound to compute spend
| AWS Reserved Instances | Deeper discounts for fixed instances | Less flexible; instance family/region locked
| Azure Reserved Instances | Strong discounts; integrated with Azure billing | Region/size commitment; limited flexibility unless exchangeable
| Azure Savings Plans | Flexible commit to spend | Forecasting required
| Azure Hybrid Benefit | Big savings on Windows/SQL licensing | Requires existing eligible licenses or SA/subscriptions

## Recommendations

- Right size first, then commit: analyze steady state usage over 2–4 weeks before buying commitments.
- Use Savings Plans for flexibility if you plan instance family migrations or use autoscaling groups.
- Use Azure Hybrid Benefit when you have eligible licenses  immediate and recurring savings.
- Combine CDN + lifecycle policies to reduce egress and storage before committing heavily to compute.

## Phase 6  Final Comparison Report

## Executive summary

- Baseline monthly estimates: AWS ≈ $536, Azure (Linux) ≈ $532, Azure (Windows w/ AHB) ≈ $482.
- Major cost drivers: outbound data transfer (egress), managed database (RDS/Azure DB), compute instance selection.
- Short-term (pay-as-you-go): Azure Linux and AWS are comparable; Azure Windows with Azure Hybrid Benefit is cheaper for Windows-heavy workloads.
- Long-term: commitment-based discounts (Savings Plans / Reserved Instances) reduce costs by ~13–21% (1–3 year ranges) depending on provider and commitment depth.

## Side-by-side cost table (baseline)

| Category | AWS (USD/mo) | Azure Linux (USD/mo) | Azure Windows w/ AHB (USD/mo) |
|---|---:|---:|---:|
| Compute (app) | 91 | 210 | 260 |
| Managed DB | 150 | (DB via VM or managed) | (DB via VM or managed) |
| Storage (object) | 12 | 9 | 9 |
| Data transfer (egress) | 185 | 178 | 178 |
| Load balancer | 30 | 25 | 25 |
| Backups / snapshots | 10 | 25 | 25 |
| Monitoring & misc | 40 | 35 | 35 |
| **Estimated total** | **536** | **532** | **482** |

## Linux vs Windows comparison

- Linux workloads: Azure and AWS show similar baseline totals; instance family choice (Graviton vs x86) impacts AWS costs significantly.
- Windows workloads: Azure Hybrid Benefit meaningfully reduces OS licensing costs on Azure; on AWS run Windows VMs with added licensing charges unless using BYOL.

## Networking cost analysis (summary)

- Egress is the largest single variable; 2 TB/month baseline leads to ~$178–185/month depending on provider.
- Use CDN (CloudFront/Azure CDN) to reduce origin egress for static assets; this often yields the largest marginal savings.
- Multi-AZ architectures increase resilience but can add inter-AZ transfer costs; minimize chatty cross AZ traffic.

## Discount & savings analysis (summary)

- 1-year commitments (Savings Plans / Reserved) yield ~13–15% monthly savings in our model.
- 3-year commitments yield deeper savings (~19–21% in our model).
- Azure Hybrid Benefit provides immediate savings for Windows workloads and compounds with reserved pricing.

## Which provider is cheaper in different scenarios

- Linux startup (variable load, cost-sensitive): AWS with Graviton instances or Azure B-series could be cheapest; use pay-as-you-go initially.
- Microsoft enterprise (Windows, SQL Server): Azure with Azure Hybrid Benefit and Reserved Instances is typically the best financial choice.
- Budget-sensitive startup: Favor spot/Graviton/B-series and CDN; AWS Savings Plans or Azure equivalent after baseline stabilizes.
- Scalable SaaS company: Evaluate Reserved + Savings Plans for baseline and autoscale with on-demand for peaks. Consider multi-cloud for redundancy, but cost management is harder.

## Business recommendations

1. Right size and run a 2–4 week usage baseline before purchasing commitments.
2. Use CDN to reduce egress; this often reduces monthly costs more than compute optimizations for traffic-heavy apps.
3. For Windows-heavy shops with existing licenses, choose Azure and apply Azure Hybrid Benefit.
4. Purchase Savings Plans / Reserved Instances only after steady-state usage is confirmed; use Savings Plans for flexibility if you expect instance-family migrations.

## Business Summary

Business Justification Summary

Choosing a cloud provider requires balancing technical fit, total cost of ownership (TCO), and business strategy. For the small SaaS invoicing application modeled here, both AWS and Azure offer production ready managed services that reduce operational overhead; the economic difference depends primarily on workload characteristics and licensing.

AWS is attractive when teams prioritize broad service variety, Graviton based instance cost efficiency, and deep ecosystem tooling. For Linux-native stacks, AWS Graviton instances typically deliver the best price/performance when code and dependencies are compatible, and Savings Plans provide flexible commitment based discounts across instance families. AWS also has mature CDN, database, and monitoring services, making it a strong choice for startups that require rapid feature velocity and a large partner ecosystem.

Azure is compelling for organizations invested in Microsoft technologies. Azure Hybrid Benefit (AHB) significantly reduces costs for Windows Server and SQL Server workloads by allowing customers to reuse existing licenses. Enterprises with existing Microsoft licensing and on-prem investments often realize substantial neart erm savings on Azure. Azure’s pricing parity for Linux is similar to AWS at small scales, but Azure integrates more tightly with Microsoft identity, management, and developer tools, easing enterprise adoption.

For startups with predominantly Linux workloads and variable demand, AWS (with Graviton and pay-as-you-go initially) often minimizes upfront cost and risk. For Microsoft centric enterprises or applications with heavy Windows/SQL Server dependencies, Azure with AHB and reserved commitments usually offers the stronger financial case. Regardless of provider, the largest controllable cost is network egress; adding a CDN and applying lifecycle policies to storage typically yields the largest marginal savings.

Recommendation: I measure 1-3 days of production usage, right-size resources, and then purchase 1 year commitments for the predictable baseline while keeping burst capacity on demand. This hybrid approach balances flexibility with savings while minimizing business risk.
