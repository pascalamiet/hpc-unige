---
title: Cost and Accounting
type: concept
tags: [cost, billing, accounting, cpu-hours, private-nodes, pricing, sreport, sacct]
sources: [02_how_cluster_works.txt, 08_utilization_and_accounting.txt, 11_faq.txt]
updated: 2026-04-16
---

# Cost and Accounting

UNIGE HPC is partially paid. All resources — CPU, memory, and GPU — are unified into a single **billing** metric (CPU-hour equivalents). See the [overview](overview.md) for the full cluster picture.

## Free allocations

- **100,000 CPU-hours (billing) per PI per year** — free of charge
- **Teaching**: free if students submit to the correct account (`--account=<PI_NAME>_teach`)
- **Private node ownership**: generates billing credits (see below)

## Billing metric (resource accounting)

All usage is converted to **CPUh equivalents** using these weights:

| Resource        | Billing weight     |
|----------------|--------------------|
| 1 CPU core     | 1 CPUh / hour      |
| 1 GB RAM       | 0.25 CPUh / hour   |
| GPU A100 40GB  | 5 CPUh / hour      |
| GPU A100 80GB  | 8 CPUh / hour      |
| GPU RTX 3090   | 5 CPUh / hour      |
| GPU RTX 4090   | 8 CPUh / hour      |
| GPU H100       | 14 CPUh / hour     |
| GPU H200       | 17 CPUh / hour     |
| GPU RTX 5090   | 10 CPUh / hour     |
| GPU RTX Pro 6000 Blackwell | 16 CPUh / hour |
| GPU V100       | 3 CPUh / hour      |
| GPU Titan RTX  | 1 CPUh / hour      |

**Example**: 2 CPUs + 20 GB RAM + 1 A100 for 1 hour = 2 + 5 + 5 = **12 CPUh billed**

Check current weights: `scontrol show partition debug-cpu | grep TRESBillingWeights`

## Pay-per-hour pricing (U1 rate for UNIGE members)

Base rate: ~0.0157 CHF/CPUh (displayed as 0.02 CHF on invoices due to rounding)

### Progressive discount tiers

| Usage (CPUh)    | Discount        |
|-----------------|-----------------|
| 0 – 199,999     | Base rate       |
| 200,000 – 499,999 | Base rate −10% |
| 500,000 – 999,999 | Base rate −20% |
| 1,000,000+      | Base rate −30%  |

## Private / rented compute nodes

Research groups can purchase or rent private nodes. Benefits:
- Higher Slurm priority on those nodes (shorter wait times)
- Max job runtime of **7 days** (vs. 4 days public)
- Billing credits usable across **all three clusters**

### Private node rules

- 15% surcharge on vendor price for infrastructure costs
- 5-year ownership period; after that, node moves to public/shared partitions
- 3-year warranty; post-warranty repairs at 100% group cost (max 420 CHF diagnostic fee)
- Group uses up to **60% of theoretical credit** from their nodes
- Minimum rental: 6 months; unused allocated resources lost at year end

### Credit calculation example (128-core node, 512 GB, 1 year)

```
(128 cores × 1.0 + 512 GB × 0.25) × 24h × 365 days × 0.6 = 1,342,848 CPUh/year
```

### Current rental node pricing (AMD CPU)

- 2×64 EPYC 7742, 512 GB: ~14,443 CHF → +15% → ~16,609 CHF → ~277 CHF/month
- Generates ~1.34M billing credits/year

### Current server purchase prices (ex-VAT, ex-15%)

- AMD CPU node (2×64 EPYC 7742, 512 GB): ~14,443 CHF
- AMD CPU node (2×96 EPYC 9754, 768 GB): ~16,464 CHF
- GPU H100 node (2×64 EPYC 9554, 768 GB, 4× H100 94GB): ~124,000 CHF + ~28,500/extra GPU
- GPU RTX4090 node (2×64 EPYC 9554, 384 GB, 8× RTX4090): ~44,000 CHF

For COINF funding: https://www.unige.ch/rectorat/commissions/coinf/appel-a-projets

## Accounting tools

### OpenXDMoD (web)

- Dashboard: https://openxdmod.hpc.unige.ch
- Shows CPUh and GPUh — **does NOT support the billing metric**
- Do not use for invoicing cross-checks; use sreport instead

### sacct (Slurm tool)

```bash
sacct -u $USER -S 2025-01-01                    # job history since date
sacct -j <jobid> --format=Start,AveCPU,State,MaxRSS,...  # job details
```

### ug_slurm_usage_per_user (UNIGE script)

```bash
ug_slurm_usage_per_user                          # your usage this month
ug_slurm_usage_per_user --pi <name> --report-type account --start 2025-01-01
ug_slurm_usage_per_user --pi <name> --all-users --aggregate  # all users under a PI
ug_slurm_usage_per_user --group private_xxx --start 2025-01-01
```

### sreport (Slurm tool)

```bash
sreport cluster AccountUtilizationByUser user=$USER start=2025-01-01 -t Hours
sreport job sizesbyaccount user=$USER PrintJobCount start=2025-01-01 end=2026-01-01
```

Note: use TRES `billing` (not default CPUh) for invoicing-aligned numbers.

### ug_getNodeCharacteristicsSummary

Lists private node inventory and billing credits for a group:
```bash
ug_getNodeCharacteristicsSummary --partitions private-<group>-gpu private-<group>-cpu \
    --cluster <cluster> --summary
```

## Acknowledgements in publications

Required by terms of use:
> "The computations were performed at University of Geneva using Baobab HPC service."

## Related pages

- [Overview](overview.md) · [Slurm](slurm.md) · [Best Practices](best-practices.md)
- [Baobab](entity-baobab.md) · [Yggdrasil](entity-yggdrasil.md) · [Bamboo](entity-bamboo.md)
