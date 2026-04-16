# sync-folder

A small tool that registers a local project directory for rsync syncing to an HPC cluster. One command sets up named push/pull aliases globally.

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
sync-folder . baobab:~/projects/my-research-project my-research
```

**Step 3 — Use the aliases:**
```bash
my-research-up      # push local → cluster
my-research-down    # pull cluster → local
```

---

## What `install.sh` does

- Symlinks `sync-folder` to `~/.local/bin/` so it's callable from anywhere
- Creates `~/.rsync-aliases.sh` — the file that stores all your project aliases
- Patches your shell config (`~/.zshrc` or `~/.bashrc`) to source that file on login
- Optionally adds `~/.local/bin` to your `$PATH` if it's missing
- Creates `~/.rsync-logs/` for cron job output

---

## What `sync-folder` does

```
sync-folder <local-path> <host:remote-path> <project-name>
```

| Argument | Example | Description |
|----------|---------|-------------|
| `local-path` | `.` or `~/work/thesis` | Local project directory (`.` = current dir) |
| `host:remote-path` | `baobab:~/projects/thesis` | Remote destination in rsync format |
| `project-name` | `thesis` | Short name used for alias names |

Interactive prompts let you:

- **Choose extra rsync flags** (--delete, --update, --checksum, --bwlimit, etc.) — base `-avzP` always included
- **Generate a `rsync-exclude.txt`** in the project directory with sensible defaults
- **Set up a cron job** to auto-push on a schedule (every 15/30 min, hourly, daily, or custom)

The command writes two aliases to `~/.rsync-aliases.sh`:
```bash
alias thesis-up='rsync -avzP ... ~/work/thesis/ baobab:~/projects/thesis/'
alias thesis-down='rsync -avzP ... baobab:~/projects/thesis/ ~/work/thesis/'
```

---

## Generated files

| File | Description |
|------|-------------|
| `~/.rsync-aliases.sh` | All project aliases — auto-maintained, human-readable |
| `~/.rsync-logs/<name>-push.log` | Cron job output (if cron enabled) |
| `<project>/rsync-exclude.txt` | Per-project exclude patterns (if created) |

`~/.rsync-aliases.sh` is **not** in this git repo — it lives on your local machine only.

---

## Updating a project

Re-run `sync-folder` with the same project name. It will show the existing aliases and ask if you want to overwrite them. Cron entries are updated idempotently (old entry replaced, not duplicated).

---

## Removing a project

Open `~/.rsync-aliases.sh` and delete the block between `# BEGIN <name>` and `# END <name>` (inclusive).

To also remove the cron job:
```bash
crontab -l | grep -v "# sync-folder:<name>" | crontab -
```

---

## Constraints

- **Project names**: letters, numbers, hyphens, and underscores only (`^[a-zA-Z0-9_-]+$`)
- **Paths with single quotes**: not supported (alias quoting limitation) — rename the directory
- **Cron + SSH**: the cron job uses the same SSH alias as your shell (e.g. `baobab`). Make sure SSH key authentication is set up so cron can connect without a password prompt. See [guides/ssh.md](../guides/ssh.md).
- **`~` in remote paths**: expanded at cron-entry write time so cron doesn't have to

---

## Example `~/.rsync-aliases.sh`

```bash
# rsync aliases — managed by sync-folder
# Each project block is delimited by BEGIN/END markers.

# BEGIN thesis
# Project: thesis
# Local:   /home/user/work/thesis
# Remote:  baobab:~/projects/thesis
# Flags:   -avzP --delete --exclude-from="/home/user/work/thesis/rsync-exclude.txt"
# Updated: 2026-04-16 14:32:00
alias thesis-up='rsync -avzP --delete --exclude-from="/home/user/work/thesis/rsync-exclude.txt" "/home/user/work/thesis/" "baobab:~/projects/thesis/"'
alias thesis-down='rsync -avzP --delete --exclude-from="/home/user/work/thesis/rsync-exclude.txt" "baobab:~/projects/thesis/" "/home/user/work/thesis/"'
# END thesis
```

---

## Related

- [guides/file-transfer.md](../guides/file-transfer.md) — rsync flags, sftp, cross-cluster transfers
- [guides/ssh.md](../guides/ssh.md) — SSH key setup (needed for password-free cron syncing)
- [wiki/_wiki_/rsync.md](../wiki/_wiki_/rsync.md) — full rsync reference
