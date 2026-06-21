# Architecture Notes — Azure Resource Organization Lab

## Design Decisions

### Why separate Resource Groups for Dev and Prod?

Resource Groups are the unit of lifecycle management in Azure. Keeping Development and Production in separate groups means:

- **Blast radius containment** — a mistake in Dev (e.g., `az group delete`) cannot touch Prod resources.
- **Independent RBAC scoping** — Contributor access for developers can be granted on `rg-3mmt labs-dev` without ever touching `rg-3mmt labs-prod`.
- **Independent cost tracking** — Azure Cost Management can filter spend per resource group, making it trivial to see "how much did Dev cost this month?"
- **Independent policy enforcement** — stricter Azure Policy (e.g., mandatory encryption, restricted SKUs) can apply only to `rg-3mmt labs-prod`.

### Why one Virtual Network instead of two?

For this lab, only the Dev environment deploys compute resources, so only one VNet was provisioned (`vnet-3mmt labs-dev-001`). In a real multi-environment setup, Production would have its own VNet (e.g., `vnet-3mmt labs-prod-001`) with non-overlapping address space (e.g., `10.1.0.0/16`) so the two environments could be peered later without IP conflicts.

### Why Standard_B1s for the VM?

The B-series "burstable" VMs are the cheapest general-purpose compute available and are eligible for the Azure free-tier (750 hours/month for the first 12 months on a free account). For a learning lab that doesn't need sustained CPU, this is the most cost-effective choice.

### Why Serverless tier for SQL Database?

Serverless compute auto-pauses after a configurable idle period (we used 60 minutes) and resumes automatically on the next query. Billing is per-second of actual compute used, plus a small storage fee. For a lab database queried only occasionally, this can reduce cost by over 90% compared to a provisioned tier.

### Why LRS for the Storage Account?

Locally Redundant Storage (LRS) keeps three copies of your data within a single datacenter. It is the cheapest redundancy option and appropriate for non-critical lab data. Production workloads would typically use ZRS (Zone-Redundant) or GRS (Geo-Redundant) for higher durability.

### Why restrict the NSG rule to a single source IP?

Opening SSH (port 22) to the entire internet (`0.0.0.0/0`) is one of the most common causes of compromised VMs — automated bots scan for open port 22 within minutes of a VM going live. Restricting the rule to the administrator's current public IP dramatically reduces the attack surface. In production, Azure Bastion or a site-to-site VPN should replace direct SSH exposure entirely.

## Scalability Considerations

This naming and organization pattern scales by:

1. **Adding numbered suffixes** (`-001`, `-002`) when multiple instances of the same resource type are needed.
2. **Adding region codes** (`-eus`, `-weu`) when the company expands to multiple Azure regions.
3. **Adding a Staging resource group** (`rg-3mmt labs-stg`) between Dev and Prod as the release pipeline matures.
4. **Splitting by business unit** if the company grows — e.g., `rg-3mmt labs-finance-prod`, `rg-3mmt labs-hr-prod`.

## Governance Layer (Optional Extension)

Azure Policy can enforce this organization automatically:

- **Require tags policy** — reject any resource creation that is missing `environment`, `owner`, `project`, `costcenter`, or `department` tags.
- **Allowed locations policy** — restrict deployments to approved regions only (e.g., East US, West Europe).
- **Allowed VM SKUs policy** — prevent expensive VM sizes from being deployed in the Dev resource group.

See `/policies/require-tags-policy.json` for a sample policy definition.
