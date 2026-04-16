# Baobab HPC — SSH Setup and Connection

## Clusters and login nodes

| Cluster   | Login node                        |
|-----------|-----------------------------------|
| Baobab    | `login1.baobab.hpc.unige.ch`     |
| Yggdrasil | `login1.yggdrasil.hpc.unige.ch`  |
| Bamboo    | `login1.bamboo.hpc.unige.ch`     |

No VPN needed — all login nodes are reachable directly from outside UNIGE.

---

## Account

- Username: your ISIS username
- Password: your ISIS password (managed at https://mdp.unige.ch — the HPC team cannot reset it)
- Request an account: https://catalogue-si.unige.ch/en/hpc
- Manage account / view expiry: https://my-account.unige.ch

---

## SSH key setup (one-time, recommended)

Key-based auth avoids typing your password on every connection.

1. **Generate a key pair** (skip if you already have one at `~/.ssh/id_rsa.pub` or `~/.ssh/id_ed25519.pub`):
   ```bash
   ssh-keygen -t ed25519 -C "your_email@unige.ch"
   ```
   Accept the default path. Set a passphrase (optional but recommended).

2. **Print your public key**:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. **Register the public key** at https://my-account.unige.ch → "My SSH public key". Paste the full contents.

4. **Wait 10–15 minutes** for the key to sync to the clusters, then connect without a password.

To register **multiple keys** (e.g. laptop + desktop), see the access documentation — Baobab supports multiple public keys.

### SSH agent (avoid re-entering passphrase)

If you set a passphrase on your key, add it to the agent once per session:
```bash
ssh-add ~/.ssh/id_ed25519
```

On macOS, add to `~/.ssh/config` to persist across reboots:
```
Host *
  AddKeysToAgent yes
  UseKeychain yes
```

---

## SSH config (`~/.ssh/config`)

Set up aliases so you can type `ssh baobab` instead of the full hostname:

```
Host baobab
  HostName login1.baobab.hpc.unige.ch
  User your_isis_username
  IdentityFile ~/.ssh/id_ed25519

Host yggdrasil
  HostName login1.yggdrasil.hpc.unige.ch
  User your_isis_username
  IdentityFile ~/.ssh/id_ed25519

Host bamboo
  HostName login1.bamboo.hpc.unige.ch
  User your_isis_username
  IdentityFile ~/.ssh/id_ed25519
```

Then connect with:
```bash
ssh baobab
```

File transfer commands (`scp`, `rsync`, `sftp`) also respect these aliases.

---

## Connecting

```bash
ssh baobab                                         # using config alias
ssh your_username@login1.baobab.hpc.unige.ch      # explicit
ssh -X baobab                                      # with X11 forwarding (GUI apps)
ssh -Y baobab                                      # trusted X11 forwarding (macOS)
```

**First connection**: you will be prompted to confirm the server fingerprint — type `yes`.

**Password prompt**: when typing your password, no characters appear on screen — this is normal Linux behavior.

---

## Login node limits

- Max **2 CPU cores** and **8 GB RAM** per user on the login node
- Use the login node only for: editing files, compiling, submitting jobs (`sbatch`), file management
- **Never run compute jobs on the login node** — use Slurm (`sbatch`, `srun`, `salloc`) on compute nodes

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No response / connection times out | fail2ban block after 3 wrong passwords | Wait 15 minutes, then retry |
| "Connection refused" | Same cause, or port 22 blocked by your network | Wait or ask your network admin |
| "Name or service not known" | Hostname typo | Check spelling; note `baobab2` was decommissioned |
| Cluster unreachable | Scheduled maintenance | Check email and https://hpc-community.unige.ch |
| X11 errors on macOS | XQuartz not installed | Install from https://www.xquartz.org |
| Locale warning on macOS | Terminal locale mismatch | Add `export LC_ALL=en_US.UTF-8` to `~/.zshrc` or `~/.bashrc` |

**fail2ban**: 3 consecutive wrong passwords → IP blocked for 15 minutes. If you're still blocked after 15 min, contact hpc@unige.ch with your username, IP address, and target cluster.

---

## SSH connection multiplexing (speed up repeated connections)

Avoid re-authenticating for every new terminal or `scp`. Add to `~/.ssh/config`:

```
Host baobab
  HostName login1.baobab.hpc.unige.ch
  User your_isis_username
  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist 10m
```

The first `ssh baobab` opens a master connection; subsequent connections reuse it instantly.

---

## Accessing compute nodes (advanced)

Compute nodes are not directly accessible from outside. You can reach a node **while your job is running** by hopping through the login node:

```bash
ssh -J baobab cpu123          # ProxyJump (OpenSSH 7.3+)
```

Or add to `~/.ssh/config`:
```
Host baobab-node
  HostName cpu123             # replace with your allocated node
  ProxyJump baobab
  User your_isis_username
```

Useful for debugging with `htop`, `nvidia-smi`, or attaching to a running process.
