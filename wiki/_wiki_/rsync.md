---
title: rsync — File Synchronization Reference
type: concept
tags: [rsync, file-transfer, sync, delta-transfer, exclude, filtering]
sources: [rsync_manpage.html, rsync-ssl_manpage.html, rsyncd-conf_manpage.html, rsync-tutorial.html]
updated: 2026-04-16
---

# rsync — File Synchronization Reference

rsync is a fast, versatile file-copying tool. Its defining feature is the **delta-transfer algorithm**: instead of retransmitting whole files, it identifies which blocks have changed and sends only those. This makes repeated syncs between a local machine and a cluster fast and bandwidth-efficient.

See [access](access.md) for how file transfer fits into the overall cluster workflow, and [data-lifecycle](data-lifecycle.md) for when and why to move data off the cluster.

---

## Transfer modes

rsync has three distinct modes depending on the separator used:

| Mode | Separator | Example |
|------|-----------|---------|
| Local copy | (no host) | `rsync src/ dest/` |
| Remote shell (SSH) | single colon `:` | `rsync user@host:path/ dest/` |
| Daemon connection | double colon `::` | `rsync host::module dest/` |

For HPC use, the **remote-shell (SSH) mode** is almost always what you want.

---

## The trailing-slash rule (critical)

The presence or absence of a trailing slash on the **source** path controls whether the directory itself or its contents are transferred:

```bash
rsync -av myfolder/  remote:~/project/myfolder/
# Copies the CONTENTS of myfolder → no extra nesting level

rsync -av myfolder   remote:~/project/
# Copies the DIRECTORY myfolder itself → creates remote:~/project/myfolder/
```

Both produce the same result on the remote, but confusing the two causes unexpected double-nesting. When in doubt, use `--dry-run` first.

The trailing slash on the **destination** has no special meaning.

---

## Common flags

### Essential

| Flag | Long form | Effect |
|------|-----------|--------|
| `-a` | `--archive` | Archive mode: recursive + preserve permissions, timestamps, symlinks, owner, group. Equivalent to `-rlptgoD`. **Start here.** |
| `-v` | `--verbose` | Show which files are transferred. Use `-vv` for more detail. |
| `-n` | `--dry-run` | Show what would happen without doing it. Always use before `--delete`. |
| `-P` | | Shorthand for `--partial --progress`: show progress bar + resume partial transfers. |
| `-u` | `--update` | Skip files that are **newer** on the destination. Useful for incremental syncs. |
| `--delete` | | Delete files on the destination that no longer exist on the source. **Dangerous** — dry-run first. |
| `-i` | `--itemize-changes` | Show a change-summary for every file: what changed and why. |
| `-z` | `--compress` | Compress data during transfer. Helpful on slow connections; skip on fast LAN (overhead not worth it). |
| `-h` | `--human-readable` | Show file sizes in human-readable units (KB, MB, etc.) |

### Useful extras

| Flag | Long form | Effect |
|------|-----------|--------|
| `-r` | `--recursive` | Recurse into directories (already included in `-a`). |
| `-c` | `--checksum` | Compare files by checksum rather than mod-time + size. Slower but catches silent bit-rot. |
| `-W` | `--whole-file` | Disable delta transfer, send complete files. Faster on very fast networks (local LAN, InfiniBand) where delta computation overhead exceeds transfer time. |
| `--bwlimit=RATE` | | Limit bandwidth (e.g. `--bwlimit=50m` for 50 MB/s). Polite on shared networks. |
| `--info=progress2` | | Show one overall progress bar for the entire transfer (cleaner than per-file progress). |
| `-m` | `--prune-empty-dirs` | Remove empty directory chains from the file list. |
| `--timeout=SECONDS` | | Set I/O timeout. Useful for long transfers over unreliable connections. |
| `--checksum-choice=STR` | | Choose checksum algorithm (e.g. `xxh128`, `md5`, `sha1`). |

### Combining flags

The most common combination for syncing to/from HPC:

```bash
# Upload a project directory (safe, shows progress, compresses)
rsync -avzP myfolder/ baobab:~/projects/myfolder/

# Dry-run before deleting anything
rsync -avzn --delete myfolder/ baobab:~/projects/myfolder/

# Same, for real
rsync -avzP --delete myfolder/ baobab:~/projects/myfolder/

# Download results
rsync -avzP baobab:~/projects/myfolder/outputs/ ./local_outputs/

# Incremental sync, skip files newer at destination
rsync -avzu myfolder/ baobab:~/projects/myfolder/

# Itemized output to see exactly what changed
rsync -avzi myfolder/ baobab:~/projects/myfolder/
```

---

## Filtering and excluding files

### Inline excludes

```bash
rsync -avz \
    --exclude='data/' \
    --exclude='*.log' \
    --exclude='__pycache__/' \
    --exclude='.ipynb_checkpoints/' \
    myfolder/ baobab:~/projects/myfolder/
```

Patterns are relative to the source root. Prefix with `/` to anchor to the source root:

```bash
--exclude='/data/'         # only excludes top-level data/, not nested ones
--exclude='data/'          # excludes any directory named data/ at any level
```

### Exclude file

```bash
rsync -avz --exclude-from='rsync-exclude.txt' myfolder/ baobab:~/projects/myfolder/
```

Where `rsync-exclude.txt` contains one pattern per line:

```
data/
*.log
*.pyc
__pycache__/
.ipynb_checkpoints/
.DS_Store
node_modules/
.git/
```

### Include overrides

`--include` patterns are evaluated before `--exclude`. This lets you whitelist specific files inside an excluded directory:

```bash
rsync -avz \
    --include='data/results/' \
    --exclude='data/' \
    myfolder/ baobab:~/projects/myfolder/
```

Order matters: rsync applies the first matching rule.

### Automatic filter files (`.rsync-filter`)

rsync can merge filter rules from per-directory `.rsync-filter` files, similar to `.gitignore`. Enable with `-F` (or `-FF` to also ignore the files themselves).

---

## Delta-transfer algorithm

rsync's default comparison is **mod-time + file size**: if both match, the file is skipped. If the file needs updating, only the changed blocks are sent (not the whole file).

| Comparison method | When to use |
|-------------------|------------|
| mod-time + size (default) | Most situations. Fast. |
| `--checksum` (`-c`) | When you suspect silent corruption, or after filesystem operations that touch timestamps. Slower (reads every file). |
| `--ignore-times` (`-I`) | Transfer every file unconditionally regardless of timestamps. |
| `--size-only` | Skip files that match in size, ignore timestamps. |

---

## Cluster-to-cluster transfers

Data is not shared between Baobab, Yggdrasil, and Bamboo. To move data between clusters efficiently, run rsync **from one cluster's login node** — this uses the high-bandwidth inter-datacenter link instead of routing through your laptop:

```bash
# From inside Baobab (after ssh baobab):
rsync -avzP ~/myproject/ login1.yggdrasil.hpc.unige.ch:~/myproject/
```

See [access](access.md) and the cluster entity pages ([Baobab](entity-baobab.md), [Yggdrasil](entity-yggdrasil.md), [Bamboo](entity-bamboo.md)) for login node hostnames.

---

## Scripting and automation

### Shell aliases

Define in `~/.zshrc` or `~/.bashrc` for repeat syncs:

```bash
alias sync-up='rsync -avzP --exclude-from=rsync-exclude.txt ./ baobab:~/projects/myproject/'
alias sync-down='rsync -avzP baobab:~/projects/myproject/outputs/ ./outputs/'
```

### Password-free operation

rsync uses SSH under the hood (single-colon mode). Configure SSH key authentication and an SSH alias (see [access](access.md)) to avoid password prompts.

### Scripted daemon access

For rsync daemon mode (double-colon), set `RSYNC_PASSWORD` in the environment or use `--password-file` to avoid interactive prompts. Don't use environment variables for passwords on shared systems where they may be visible to other users.

---

## rsync daemon mode (advanced)

When the destination uses `::` (double colon) or an `rsync://` URL, rsync connects directly to a TCP daemon on port 873 rather than spawning a process over SSH. This is used for public mirrors and some institutional transfer services — it is not the typical mode for HPC cluster transfers.

```bash
# Daemon mode examples
rsync -av host::modulename /dest/          # list then download
rsync -av rsync://host/modulename /dest/   # URL form
```

### rsync-ssl

`rsync-ssl` is a helper script that wraps daemon-mode connections with SSL/TLS encryption (via openssl or stunnel). It uses port 874 by default and is configured via environment variables (`RSYNC_SSL_TYPE`, `RSYNC_SSL_CERT`, etc.):

```bash
rsync-ssl -aiv example.com::mod/ dest/
rsync-ssl --type=openssl -aiv example.com::mod/ dest/
```

This is rarely needed for UNIGE HPC transfers, which go over SSH.

### rsyncd.conf

rsync daemons are configured via `rsyncd.conf` (typically `/etc/rsyncd.conf`). The file defines **modules** — named directory trees exported to clients — plus global settings for authentication, access control, logging, and chroot. HPC users generally don't need to interact with daemon config; it is managed by the HPC team.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Extra nesting level in destination | Missing trailing slash on source | Add `/` after source path |
| Transfer doesn't skip unchanged files | Timestamps differ (e.g. after `tar` extraction) | Use `--checksum` or `--ignore-times` for one-time transfer |
| Permission errors | Remote filesystem doesn't support all attributes | Drop `-a`, use `-rtz` instead; skip `--owner`/`--group` |
| Very slow on large directories | Delta computation overhead on fast link | Try `--whole-file` on local LAN or InfiniBand |
| `--delete` removed unexpected files | Source had stale excludes, or wrong source path | Always dry-run with `-n` before `--delete` |
| Rsync hangs partway through | I/O timeout on idle connection | Add `--timeout=60` |

---

## Related pages

- [Access](access.md) · [Data Lifecycle](data-lifecycle.md) · [Best Practices](best-practices.md)
- [Storage](storage.md) · [Overview](overview.md)
- [Baobab](entity-baobab.md) · [Yggdrasil](entity-yggdrasil.md) · [Bamboo](entity-bamboo.md)
