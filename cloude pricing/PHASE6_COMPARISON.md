# Phase 6  Final Comparison Report

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
- Multi-AZ architectures increase resilience but can add inter-AZ transfer costs; minimize chatty cross-AZ traffic.

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

1. Right-size and run a 2–4 week usage baseline before purchasing commitments.
2. Use CDN to reduce egress; this often reduces monthly costs more than compute optimizations for traffic-heavy apps.
3. For Windows-heavy shops with existing licenses, choose Azure and apply Azure Hybrid Benefit.
4. Purchase Savings Plans / Reserved Instances only after steady-state usage is confirmed; use Savings Plans for flexibility if you expect instance-family migrations.

## Deliverables included in repository

- `cloude pricing/PHASE1_SPEC.md`  Phase 1 planning
- `cloude pricing/PHASE2_AWS.md`  AWS cost estimation
- `cloude pricing/PHASE3_AZURE.md`  Azure cost estimation
- `cloude pricing/PHASE4_NETWORKING.md`  Networking analysis
- `cloude pricing/PHASE5_DISCOUNTS.md`  Discounts & savings
- `cloude pricing/savings_1yr.csv`  Modeled 1-year savings
- `cloude pricing/savings_3yr.csv`  Modeled 3-year savings
- `cloude pricing/aws_estimate.csv`, `azure_estimate.csv`, `comparison_estimates.csv`  baseline estimates

---

If you want, I can:
- Generate simple charts (PNG) from the CSVs and add them to `cloude pricing/screenshots/`.
- Produce a printable PDF report combining all phases.

Next: generate `summary.txt` (Phase 7) and the repository README structure (Phase 8). Confirm and I'll proceed.
