# RBAC Role Assignments — Documentation

## Summary Table

| Assignment | Role | Scope | Principal | Justification |
|---|---|---|---|---|
| 1 | Owner | `rg-3mmt labs-dev` | Lab Admin (you) | Full control needed to manage the lab, including granting access to others |
| 2 | Contributor | `rg-3mmt labs-dev` | Developer User | Developers need to deploy and manage resources but should not control access |
| 3 | Reader | `rg-3mmt labs-prod` | Auditor User | Auditors and finance stakeholders need visibility without risk of changes |

## Role Definitions

### Owner

**Permissions:** `*` (all actions on all resource types within scope, including RBAC management)

**When to assign:**

- The person ultimately accountable for the resource group's resources and security
- Someone who must be able to grant or revoke access for others

**Security implications:**

- An Owner can assign Owner to anyone else, including themselves on other scopes if they also have access there
- Compromise of an Owner credential is the worst-case scenario — the attacker can delete all resources AND lock out legitimate users by changing role assignments
- Always pair Owner accounts with multi-factor authentication (MFA) and conditional access policies

### Contributor

**Permissions:** All actions except managing access (`Microsoft.Authorization/*` write operations are denied)

**When to assign:**

- Developers, DevOps engineers, automation service principals that need to create/update/delete resources
- Anyone who needs full operational control but should not be able to alter who has access

**Security implications:**

- A compromised Contributor account cannot escalate itself to Owner — this is the key safety property
- Contributor can still delete production data if scoped too broadly, so always scope to the narrowest resource group or resource possible
- Contributor can read secrets stored in some resource configurations (e.g., connection strings) — pair with Key Vault and least-privilege secret access for sensitive credentials

### Reader

**Permissions:** Read-only — can view resource properties and configuration but cannot create, modify, or delete anything

**When to assign:**

- Auditors, compliance teams, finance/cost-management stakeholders
- Anyone who needs dashboards/visibility but has no operational responsibility

**Security implications:**

- Lowest-risk role; a compromised Reader account cannot cause direct damage
- Reader can still see resource configuration, which may include non-secret metadata (names, sizes, regions, tags) — if any of that is sensitive, consider scoping Reader even more narrowly to specific resources rather than the whole resource group

## The Least-Privilege Principle

> Grant the minimum level of access required for a person or service to perform their job — no more.

**Why this matters:**

1. **Reduces blast radius** — if an account is compromised (phished, leaked credential, malicious insider), the damage is limited to what that role can do.
2. **Reduces accidental damage** — a Contributor who fat-fingers a command cannot accidentally grant a stranger access to the subscription; an Owner could.
3. **Simplifies auditing** — when access is scoped narrowly, security reviews can quickly confirm "this person can do X and only X" rather than untangling broad permissions.
4. **Supports compliance frameworks** — SOC 2, ISO 27001, and similar standards explicitly require least-privilege access controls.

**Practical guidance used in this lab:**

- The Lab Admin (you) is Owner only on `rg-3mmt labs-dev` — not on the whole subscription, and not on `rg-3mmt labs-prod`.
- The same person can hold different roles at different scopes (Owner on Dev, Reader on Prod) — RBAC is always scope-specific, never global by default.
- Roles are assigned at the Resource Group level (not the subscription level) wherever possible, to keep the blast radius as small as it can be while still being practical.

## Verifying Role Assignments

```bash
# List all role assignments for a specific scope
az role assignment list --scope "$(az group show --name rg-3mmt labs-dev --query id -o tsv)" --output table

# List all role assignments for the currently signed-in user, across all scopes
az role assignment list --assignee "$(az ad signed-in-user show --query id -o tsv)" --all --output table

# Check what actions a specific role actually permits
az role definition list --name "Contributor" --query "[].permissions" --output json
```
