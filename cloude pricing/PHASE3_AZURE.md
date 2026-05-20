# Phase 3  Azure Cost Estimation

This document guides using the Azure Pricing Calculator and provides example monthly estimates for both Linux and Windows VM scenarios (including Azure Hybrid Benefit).

## Recommended Azure regions

- Primary recommendation: `East US (eastus)` — good service coverage and typical price competitiveness.
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
   - Quantity: baseline 2 instances, autoscale 2–6; estimate average usage 3 instances
   - OS: Linux (no Windows licensing charge)
   - Managed disk: Premium SSD P10 (128 GB) or 30 GB OS disk as needed

2. Windows VM scenario (with Azure Hybrid Benefit)
   - VM size: `Standard_D2s_v3` equivalent (2 vCPU, 8 GB RAM)
   - Quantity: baseline 2 instances, average 3
   - OS: Windows Server — apply Azure Hybrid Benefit to reuse existing Windows Server licenses with Software Assurance or eligible subscriptions to reduce OS cost
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

3. Add "Storage — Blob Storage"
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

## Estimated monthly pricing (approximate — use Azure Calculator for exact values)

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

- Windows VMs without Azure Hybrid Benefit will be noticeably higher due to OS licensing — Hybrid Benefit reduces the OS portion.
- Azure often bundles some networking efficiencies; using Azure CDN reduces egress for static content.

## Explain Azure Hybrid Benefit

- Azure Hybrid Benefit (AHB) lets you use existing on-premises Windows Server and SQL Server licenses with Software Assurance, or eligible subscriptions, to save on Azure VM OS and SQL licensing costs.
- For Windows VMs, AHB can reduce VM pricing by removing the OS license surcharge. Savings depend on VM size and region.
- Use AHB when you have active license coverage; otherwise Windows pay-as-you-go rates apply.

## Azure pricing advantages and disadvantages

Advantages:

- Strong discounts for Windows workloads via Azure Hybrid Benefit.
- First-class integration for Microsoft products (Active Directory, SQL Server licensing, Windows tools).
- Transparent per-minute billing and hybrid scenarios.

Disadvantages:

- Some VM families are more expensive vs AWS for equivalent CPU/memory without careful selection.
- Outbound data transfer remains a major cost driver similar to AWS.

## Cost optimization recommendations (Azure)

- Apply Azure Hybrid Benefit for Windows workloads when eligible.
- Use B-series burstable VMs for low baseline CPU workloads to reduce steady-state cost.
- Use Azure CDN to reduce egress costs for static assets.
- Use Reserved VM Instances (1- or 3-year) or Azure Savings Plans for compute-heavy predictable workloads.
- Use lifecycle management for Blob Storage: move to Cool/Archive for older objects.

## Screenshots to capture

- VM configuration for Linux scenario in the Azure Pricing Calculator
- VM configuration for Windows scenario with Azure Hybrid Benefit toggled
- Blob Storage configuration (500 GB Hot)
- Load Balancer / Application Gateway configuration
- Backup (Recovery Services vault) configuration
- Final combined estimate summary

---

## Markdown-ready summary (for README)

```
Phase 3 — Azure Cost Estimation Summary

- Region: East US
- Linux scenario monthly example: $~532
- Windows scenario with Azure Hybrid Benefit monthly example: $~482
- Major drivers: VM compute, data egress, backup retention
- Optimization: Azure Hybrid Benefit, B-series VMs, Azure CDN, Reserved Instances

Notes: These are example estimates. Use the Azure Pricing Calculator with exact VM SKUs and backup retention details for an authoritative quote.
```

---

Next steps:

- I can produce a CSV export of both AWS and Azure estimates and a side-by-side cost table for the repository. Confirm and I'll generate them.
