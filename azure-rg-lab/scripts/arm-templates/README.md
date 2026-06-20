# ARM Templates

This folder is the destination for ARM template exports generated during the lab.

After running Phase 9 (Lifecycle Management), the script `09-cleanup.sh` will export the Development resource group's configuration here as:

```
rg-3mmt labs-dev-backup.json
```

This file is created automatically — it does not need to be created manually. It captures the **configuration** of all resources in the resource group (not the data), so the infrastructure could be redeployed later via:

```bash
az deployment group create \
  --resource-group rg-3mmt labs-dev \
  --template-file rg-3mmt labs-dev-backup.json
```
