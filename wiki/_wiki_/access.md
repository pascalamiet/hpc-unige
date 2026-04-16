---
title: Access — SSH, File Transfer, OpenOnDemand
type: concept
tags: [ssh, access, file-transfer, x2go, openondemand, scp, rsync]
sources: [03_access_cluster.txt, 01_linux.txt, 11_faq.txt]
updated: 2026-04-16
---

# Access — SSH, File Transfer, OpenOnDemand

How to connect to UNIGE HPC clusters. See the [overview](overview.md) for what you can do once connected.

## Prerequisites

- Active ISIS account (or outsider invitation from a PI)
- Basic Linux/Bash knowledge (clusters run Rocky Linux 9)
- SSH public key registered in your UNIGE account

## Login nodes

| Cluster   | Hostname                          |
|-----------|-----------------------------------|
| Baobab    | `login1.baobab.hpc.unige.ch`     |
| Yggdrasil | `login1.yggdrasil.hpc.unige.ch`  |
| Bamboo    | `login1.bamboo.hpc.unige.ch`     |

## SSH access

```bash
ssh username@login1.baobab.hpc.unige.ch
```

- Password = your **ISIS password** (managed at mdp.unige.ch — HPC team cannot reset it)
- When typing password, **no characters appear** — this is normal Linux behavior
- **fail2ban**: 3 wrong password attempts → your IP is blocked for 15 minutes
- Public key authentication is supported and recommended

### SSH public key setup

Check or update your key at:
- UNIGE members: https://my-account.unige.ch
- Outsiders: https://applicant.unige.ch/main/outsider-info/update/

Multiple SSH keys are supported — see the access documentation.

### Connection troubleshooting

| Symptom | Likely cause |
|---------|-------------|
| No response / timeout | fail2ban block (wait 15 min) or network blocks port 22 |
| "Connection refused" | Too many failed attempts |
| "Name or service not known" | Hostname typo; note: `baobab2` was decommissioned |
| Cluster under maintenance | Check email and https://hpc-community.unige.ch |

Mac users needing X11: install XQuartz.  
Mac keyboard issues with X2Go: see the FAQ in the documentation.

## Login node limits

- **2 CPU cores** and **8 GB RAM** per user on the login node
- Only compile, edit files, and submit jobs here
- **Never run compute jobs on the login node**

## File transfer

### SCP

```bash
# Upload to cluster
scp local_file.txt username@login1.baobab.hpc.unige.ch:~/destination/

# Download from cluster
scp username@login1.baobab.hpc.unige.ch:~/results/output.txt ./local_dir/
```

### Rsync (recommended for directories)

```bash
# Transfer from Baobab to Yggdrasil (run from Baobab login)
rsync -aviuzP my_project/ login1.yggdrasil.hpc.unige.ch:~/my_project/
```

Common rsync flags: `-a` (archive), `-v` (verbose), `-i` (itemized), `-u` (skip newer dest files), `-z` (compress), `-P` (partial + progress), `-n` (dry run).

### SWITCHfilesender

For large files via browser download:
```bash
# Setup (one time)
mkdir ~/.filesender
wget https://filesender.switch.ch/clidownload.php -O filesender.py
wget "https://filesender.switch.ch/clidownload.php?config=1" -O ~/.filesender/filesender.py.ini
# Edit ~/.filesender/filesender.py.ini with your email and API key

# Upload
module load GCC Python
python3 filesender.py -p -r recipient@unige.ch myfile.tar.gz
```

## OpenOnDemand (Baobab only)

Web portal with GUI apps — no SSH needed for basic use:  
https://openondemand.baobab.hpc.unige.ch

Supports: JupyterLab, RStudio, Matlab, VSCode, and more. Uses `public-interactive-cpu` partition.

Outsider users: if you get "failed to map user" error, visit the Session page and send a screenshot to hpc@unige.ch for manual activation.

## X2Go (graphical desktop)

X2Go provides a full graphical desktop session on the login node. Useful for GUI applications before submitting jobs.

Common X2Go issues:
- Quota exceeded → fix by freeing up `$HOME` space
- Conda in `.bashrc` → comment out the `conda initialize` block
- If stuck: back up `~/.bashrc`, `~/.Xauthority`, `~/.x2go`, `~/.local/session`, `~/.config/xfce` and try again

## Accounts

### PI registration

PIs must be ISIS account holders with long-term validity. Responsible for:
- Inviting users
- Knowing what data is stored
- Managing departing users' data

### User accounts

- Non-student accounts (PhD, postdoc, researcher): expire with your UNIGE contract + ~6 month grace period
- Student accounts: check with `chage -l yourusername`
- After departure: PI can invite you back as an outsider to maintain collaboration

### Teaching accounts

Teachers request via dw.unige.ch (or hpc@unige.ch):
- Account `<PI_NAME>_teach` created
- Students submit with `--account=<PI_NAME>_teach` → free of charge
- Optional shared storage at `/home/share/<PI_NAME>_teach`

## Mounting external storage (NASAC)

```bash
dbus-launch bash
gio mount smb://nasac-server.unige.ch/share_name
# Credentials: ISIS username, domain ISIS
# Data available at /run/user/<uid>/gvfs/ or ~/.gvfs
gio mount -u smb://nasac-server.unige.ch/share_name   # unmount
```

For scripted access: store credentials in a file and pipe to `gio mount`.

## Related pages

- [Overview](overview.md) · [Best Practices](best-practices.md) · [Storage](storage.md)
- [Software Modules](software-modules.md) · [Slurm](slurm.md)
