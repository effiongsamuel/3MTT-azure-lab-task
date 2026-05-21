# Phase 4  Networking Cost Analysis

This document compares networking costs for AWS and Azure for the Phase 1 application and explains multi-zone, outbound, and load-balancer transfer impacts.

## Pricing components to compare

- Inter-AZ / inter-zone data transfer (between availability zones)
- Outbound internet (egress) data transfer
- Load balancer data processing and bandwidth charges
- NAT Gateway / egress gateway costs (if used)

## Key vendor behaviors (summary)

- AWS: charges for data transfer between AZs within the same region for some services (e.g., AZ-to-AZ traffic for EC2 across AZs often billed per-GB). Internet egress billed per-GB with tiered pricing. Load balancers (ALB/NLB) charge hourly + LCU/data processed.
- Azure: charges for inter-zone or inter-region traffic vary; intra-region zone traffic often billed, but specifics depend on service. Outbound to internet billed per-GB. Load Balancer / Application Gateway have processing and data charges.

## Inter-zone traffic pricing (typical formulas)

- AWS inter-AZ transfer: Cost_interAZ = GB_transferred × rate_interAZ (e.g., $0.01–$0.02/GB depending on region)
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

- Pros: higher availability and resilience; traffic localized within zone reduces cross AZ egress if clients are zonal-aware.
- Cons: increased inter-zone replication/sync costs for stateful services (DB replication, shared caches), possible cross-zone load balancing charges.
- Recommendation: Minimize cross-AZ chatter  use regional services (managed DB Multi-AZ is optimized) and prefer async replication where possible.

## Hidden networking costs to watch for

- NAT Gateway / egress gateway per-hour and per-GB charges
- Cross-region replication costs (DB or object replication)
- PrivateLink / VPC endpoints data processing costs
- VPN/ExpressRoute / Direct Connect port and data fees for hybrid setups

## Scalability impact and real-world examples

- Example 1  Read-replica sync: a reporting replica replicates 500 GB/month from primary. If cross AZ at $0.02/GB = $10/month  small.
- Example 2  Backup and restore: Restoring a 200 GB snapshot across regions will incur regional transfer fees; plan backup retention and location to optimize.
- Example 3  CDN impact: Offloading 1.5 TB of static assets to CDN reduces origin egress by 75%  direct egress cost savings significant.

## Networking comparison table (summary)

| Category | AWS (typical) | Azure (typical) |
|---|---:|---:|
| Inter-AZ transfer | ~$0.01–$0.02/GB | region-dependent, often similar |
| Outbound internet | ~$0.09/GB (first TB ranges higher) | ~$0.087/GB (varies by zone) |
| Load balancer | hourly + LCU/data | hourly + data processing (App GW) |
| NAT Gateway | per-hour + per-GB | similar per-hour + per-GB |

## Recommendations to reduce networking costs

- Use CDN for static assets; set long TTLs for infrequently changing content.
- Aggregate and batch cross-zone replication to off-peak windows where possible.
- Use regional managed services to avoid custom cross-AZ traffic when feasible.
- Monitor egress with cloud billing alerts and use cost allocation tags to attribute traffic to services.

---

## Tiered per-GB examples and cost table

Assumed example tiered rates (typical, region-dependent):

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
- Between 10–50 TB/month: small differences in the next tier rates begin to matter  negotiate or use Savings/commitment options.
- Above 50 TB/month: consider direct peering, CDN, or negotiated enterprise discounts to materially reduce egress cost.
