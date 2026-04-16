# Baobab HPC Cluster — Access Guide

## Clusters

| Cluster | Login node |
|---|---|
| Baobab | `login1.baobab.hpc.unige.ch` |
| Yggdrasil | `login1.yggdrasil.hpc.unige.ch` |
| Bamboo | `login1.bamboo.hpc.unige.ch` |

No VPN needed — reachable from outside Unige directly.

---

## Quick Connect

SSH config is already set up at `~/.ssh/config`:

```
Host baobab
  HostName login1.baobab.hpc.unige.ch
  User amiet
```

Connect with:
```bash
ssh baobab
```

---

## Account

- Username: `amiet` (ISIS credentials)
- Request/manage account: https://dw.unige.ch/openentry.html?tid=hpc
- Authentication: ISIS password **or** SSH key registered in your ISIS profile

---

## SSH Key Setup (one-time)

1. Generate a key (if you don't have one):
   ```bash
   ssh-keygen -t rsa
   ```
2. Copy your public key:
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
3. Register it at: https://my-account.unige.ch/ → "My SSH public key"
4. Wait 10–15 min for sync, then connect without a password.

---

## File Transfer

```bash
# Copy local file to cluster
scp myfile.txt baobab:/path/on/cluster/

# Copy folder (one-time, manual)
rsync -avz --exclude-from='rsync-exclude.txt' ./ baobab:/home/users/a/amiet/tst-llm/

# Download from cluster to local
scp baobab:/home/users/a/amiet/tst-llm/outputs/distances/simulation_mixture_mean-decay_d50_n100.csv ~/Dropbox/01_phd/01_research/tst-llm/outputs/distances
```

### rsync vs scp

`rsync` is generally better for large or repeat transfers:
- **Not automatic** — you run it manually each time
- **Skips unchanged files** — only transfers new/modified files on repeat runs
- **Resumes interrupted transfers**
- Add `--delete` to remove files on the cluster that no longer exist locally

`scp` is simpler for one-off single file transfers.

**Run rsync from your local machine** (before `ssh baobab`), not from inside the cluster.

On Windows: use FileZilla (avoid the "sponsored" download).

### Excluding folders

Use `--exclude` to skip specific subfolders:

```bash
rsync -avz --exclude='subfolder/' myfolder/ baobab:/path/on/cluster/
```

Or use an exclude file:

```bash
rsync -avz --exclude-from='rsync-exclude.txt' ./ baobab:/path/on/cluster/
```

Where `rsync-exclude.txt` contains one pattern per line:

```
data/data_cleaned/
*.log
__pycache__/
```

### Project shortcuts

The following aliases are defined in `~/.zshrc` for syncing specific projects:

```bash
# Sync tst-llm project (run from project root)
sync-hpc-tst-llm
# Expands to: rsync -avz --exclude-from=rsync-exclude.txt ~/Dropbox/01_phd/01_research/tst-llm/ baobab:/home/users/a/amiet/tst-llm/
```

Excluded folders are defined in `rsync-exclude.txt` in the project root. Must be run from the project root directory.

---

## Notes

- Wrong password 3 times → banned for 15 minutes
- First connection: confirm the server fingerprint when prompted (type `yes`)
- Inactive accounts (1 year) are flagged for deletion; you get an email warning first
- Compute nodes are not directly accessible — must go through the login node, and only while a job is running on that node
