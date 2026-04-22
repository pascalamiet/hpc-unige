# hpc-sync

A small tool that registers a local project directory for rsync syncing to an HPC cluster. One command sets up global `hpc-up` / `hpc-down` sync commands.

---

## Quick start

**Step 1 — Install once:**
```bash
bash /path/to/hpc-unige/sync/install.sh
source ~/.zshrc   # (or ~/.bashrc)
```

**Step 2 — Register a project (from any directory, any time):**
```bash
cd ~/my-research-project
hpc-sync . baobab:~/projects/my-research-project my-research
```

**Step 3 — Use the commands:**
```bash
hpc-up my-research      # push local → cluster
hpc-down my-research    # pull cluster → local
```

---

## What `install.sh` does

- Symlinks `hpc-sync` to `~/.local/bin/` so it's callable from anywhere
- Creates `~/.rsync-aliases.sh` — the file that stores your sync commands
- Patches your shell config (`~/.zshrc` or `~/.bashrc`) to source that file on login
- Optionally adds `~/.local/bin` to your `$PATH` if it's missing
- Creates `~/.rsync-logs/` for cron job output

---

## What `hpc-sync` does

```
hpc-sync <local-path> <host:remote-path> <project-name>
```

| Argument | Example | Description |
|----------|---------|-------------|
| `local-path` | `.` or `~/work/thesis` | Local project directory (`.` = current dir) |
| `host:remote-path` | `baobab:~/projects/thesis` | Remote destination in rsync format |
| `project-name` | `thesis` | Short name used with `hpc-up` / `hpc-down` |

Interactive prompts let you:

- **Choose extra rsync flags** (--delete, --update, --checksum, --bwlimit, etc.) — base `-avzP` always included
- **Generate a `rsync-exclude.txt`** in the project directory with sensible defaults
- **Choose the `hpc-down` download scope** — either the whole remote project or a specific remote subfolder such as `outputs`
- **Set up a cron job** to auto-push on a schedule (every 15/30 min, hourly, daily, or custom)

The command registers the project in `~/.rsync-aliases.sh`, which exposes two global commands:
```bash
hpc-up thesis
hpc-down thesis
```

If you choose a specific download subfolder during registration, `hpc-down thesis` syncs only that remote subfolder into the matching local subfolder. For example, choosing `outputs` makes it pull:

```text
baobab:~/projects/thesis/outputs/  ->  ~/work/thesis/outputs/
```

---

## Generated files

| File | Description |
|------|-------------|
| `~/.rsync-aliases.sh` | All registered project sync commands — auto-maintained, human-readable |
| `~/.rsync-logs/<name>-push.log` | Cron job output (if cron enabled) |
| `<project>/rsync-exclude.txt` | Per-project exclude patterns (if created) |

`~/.rsync-aliases.sh` is **not** in this git repo — it lives on your local machine only.

---

## Updating a project

Re-run `hpc-sync` with the same project name. It will show the existing commands and ask if you want to overwrite them. Cron entries are updated idempotently (old entry replaced, not duplicated).

---

## Removing a project

Open `~/.rsync-aliases.sh` and delete the block between `# BEGIN <name>` and `# END <name>` (inclusive).

To also remove the cron job:
```bash
crontab -l | grep -v "# hpc-sync:<name>" | crontab -
```

---

## Constraints

- **Project names**: letters, numbers, hyphens, and underscores only (`^[a-zA-Z0-9_-]+$`)
- **Paths with single quotes**: not supported (generated shell quoting limitation) — rename the directory
- **Cron + SSH**: the cron job uses the same SSH alias as your shell (e.g. `baobab`). Make sure SSH key authentication is set up so cron can connect without a password prompt. See [guides/ssh.md](../guides/ssh.md).
- **`~` in remote paths**: expanded at cron-entry write time so cron doesn't have to

---

## Example `~/.rsync-aliases.sh`

```bash
# rsync project commands — managed by hpc-sync
# Use hpc-up <name> and hpc-down <name> after registering a project.
# Each project block is delimited by BEGIN/END markers.

# BEGIN HPC DISPATCHERS
hpc-up() { ... }
hpc-down() { ... }
# END HPC DISPATCHERS

# BEGIN thesis
# Project: thesis
# Local:   /home/user/work/thesis
# Remote:  baobab:~/projects/thesis
# Down:    baobab:~/projects/thesis/outputs -> /home/user/work/thesis/outputs
# Flags:   -avzP --delete --exclude-from="/home/user/work/thesis/rsync-exclude.txt"
# Updated: 2026-04-16 14:32:00
__hpc_up_thesis() {
  rsync -avzP --delete --exclude-from="/home/user/work/thesis/rsync-exclude.txt" "/home/user/work/thesis/" "baobab:~/projects/thesis/"
}
__hpc_down_thesis() {
  mkdir -p "/home/user/work/thesis/outputs" && rsync -avzP --delete --exclude-from="/home/user/work/thesis/rsync-exclude.txt" "baobab:~/projects/thesis/outputs/" "/home/user/work/thesis/outputs/"
}
# END thesis
```

---

## Related

- [guides/file-transfer.md](../guides/file-transfer.md) — rsync flags, sftp, cross-cluster transfers
- [guides/ssh.md](../guides/ssh.md) — SSH key setup (needed for password-free cron syncing)
- [wiki/_wiki_/rsync.md](../wiki/_wiki_/rsync.md) — full rsync reference
