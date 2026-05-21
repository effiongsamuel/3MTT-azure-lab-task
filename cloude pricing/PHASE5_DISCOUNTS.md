# Phase 5  Discount & Savings Analysis

This document compares AWS and Azure discount mechanisms and shows example savings for the Phase 1 application.

## Overview

- Commitment based discounts reduce compute and sometimes licensing costs in exchange for 1 or 3 year commitments.
- Key AWS mechanisms: Reserved Instances (RIs) and Savings Plans.
- Key Azure mechanisms: Reserved VM Instances (RIs), Azure Savings Plans, and Azure Hybrid Benefit (AHB) for Windows/SQL Server licensing.

## AWS: Savings Plans vs Reserved Instances

- Reserved Instances (RIs): commit to specific instance family/region for 1 or 3 years. Offer up to ~30–60% savings vs on-demand depending on payment option (partial/ all upfront).
- Savings Plans: commit to $/hour usage for 1 or 3 years and get flexible discounts across instance families and regions. Compute Savings Plans are more flexible than RIs.

Example (EC2 compute):

- Baseline EC2 monthly (on-demand): $91 → annual $1,092
- 1-year Savings Plan ~30% savings → annual ~$764 (monthly ~$64) → monthly saving ~$27

Pros:

- Savings Plans: flexible application across instance families and regions.
- RIs: deeper discounts for specific, steady-state instances.

Cons:

- Commitments require forecasting; changing architectures can undercut savings.

## Azure: Reserved Instances, Savings Plans, and Azure Hybrid Benefit

- Azure Reserved VM Instances: commit to VM types/region for 1 or 3 years; typical savings 30–55%.
- Azure Savings Plans: commit to spend for compute for 1 or 3 years  similar flexibility to AWS Savings Plans.
- Azure Hybrid Benefit (AHB): re-use existing Windows Server / SQL Server licenses with Software Assurance or eligible subscriptions to remove OS licensing cost from VM pricing.

Example (Windows VM + AHB + Reserved):

- Baseline Windows monthly (on-demand): $260 → annual $3,120
- Apply Azure Hybrid Benefit: -$60/mo → $200/mo → annual $2,400
- Add 1-year Reserved Instance 35% discount → $1,560/yr → monthly ~$130 (total savings from on-demand ~50%)

## Commitment-based pricing vs Pay-as-you-go

- Pay-as-you-go: maximum flexibility, no commitment, higher unit cost.
- Commitment (1–3 year): lower unit cost, risk if usage patterns change.
- Use a mix: reserve for steady baseline, use on-demand for burst/variable traffic.

## Best use cases

- Startups with uncertain load: begin pay-as-you-go; reserve only stable baseline later.
- Enterprises with predictable steady state workloads: use RIs/Savings Plans for large savings.
- Windows-heavy workloads: apply Azure Hybrid Benefit for substantial licensing savings.

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

- Right-size first, then commit: analyze steady-state usage over 2–4 weeks before buying commitments.
- Use Savings Plans for flexibility if you plan instance-family migrations or use autoscaling groups.
- Use Azure Hybrid Benefit when you have eligible licenses  immediate and recurring savings.
- Combine CDN + lifecycle policies to reduce egress and storage before committing heavily to compute.

Next steps:

- I can model specific 1- and 3-year savings numbers for EC2 and Azure VM lines using the project's assumed baseline (I already have EC2 $91/mo and AWS RDS/etc.). Confirm and I'll produce a savings CSV and plots.
