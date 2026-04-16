# Baobab HPC — File Transfer

Assumes SSH is already configured with an alias (e.g. `baobab`). See [ssh.md](ssh.md) for setup.

**Run all transfer commands from your local machine**, not from inside the cluster.

---

## Quick reference

| Tool | Best for |
|------|---------|
| `scp` | Simple one-off file copies |
| `rsync` | Large transfers, repeated syncs, incremental updates |
| `sftp` | Interactive browsing + transfer |
| FileZilla / WinSCP | Windows or GUI preference |
| SWITCHfilesender | Sending files to collaborators via browser |

---

## scp — simple copies

```bash
# Upload: local → cluster
scp myfile.txt baobab:/path/on/cluster/
scp -r myfolder/ baobab:/path/on/cluster/

# Download: cluster → local
scp baobab:/path/on/cluster/output.csv ./local_dir/

# Multiple files
scp file1.py file2.py baobab:~/project/
```

`scp` is simple but transfers everything unconditionally — no skipping unchanged files.

---

## rsync — preferred for most use cases

rsync only transfers files that have changed, making repeat syncs fast. It also resumes interrupted transfers.

### Basic upload

```bash
rsync -avz myfolder/ baobab:/path/on/cluster/myfolder/
```

Note the trailing slash on the source: `myfolder/` syncs the **contents**; `myfolder` (no slash) syncs the **directory itself** (adds an extra nesting level).

### Basic download

```bash
rsync -avz baobab:/path/on/cluster/outputs/ ./local_outputs/
```

### Common flags

| Flag | Effect |
|------|--------|
| `-a` | Archive mode: recursive, preserves permissions, timestamps, symlinks |
| `-v` | Verbose output |
| `-z` | Compress data during transfer (useful on slow connections) |
| `-P` | Show progress bar + resume partial transfers |
| `-u` | Skip files that are newer on the destination |
| `-n` / `--dry-run` | Show what would be transferred without doing it |
| `--delete` | Remove files on the destination that no longer exist on the source |
| `-i` | Itemized output: shows what changed and why for each file |

### Dry run first (recommended before `--delete`)

```bash
rsync -avzn --delete myfolder/ baobab:/path/on/cluster/myfolder/
```

Review the output, then remove `-n` to execute.

---

## Excluding files and folders

### Inline exclude

```bash
rsync -avz --exclude='data/' --exclude='*.log' --exclude='__pycache__/' \
    myfolder/ baobab:/path/on/cluster/myfolder/
```

### Exclude file

```bash
rsync -avz --exclude-from='rsync-exclude.txt' myfolder/ baobab:/path/on/cluster/myfolder/
```

Where `rsync-exclude.txt` contains one pattern per line:

```
data/data_cleaned/
*.log
__pycache__/
.DS_Store
*.pyc
.ipynb_checkpoints/
```

Patterns are relative to the source directory. Prefix with `/` to anchor to the root of the source.

---

## Shell aliases for repeat syncs

Define project-specific sync commands in `~/.zshrc` or `~/.bashrc`:

```bash
# Sync a project to the cluster (run from project root)
alias sync-to-hpc='rsync -avzP --exclude-from=rsync-exclude.txt ./ baobab:~/projects/myproject/'

# Download outputs from cluster
alias sync-from-hpc='rsync -avzP baobab:~/projects/myproject/outputs/ ./outputs/'
```

Reload with `source ~/.zshrc`, then just run `sync-to-hpc`.

---

## sftp — interactive transfer

Useful when you want to browse the remote filesystem before deciding what to transfer:

```bash
sftp baobab
```

Inside the `sftp` shell:
```
ls                    # list remote
lls                   # list local
cd /remote/path       # change remote dir
lcd /local/path       # change local dir
get remote_file       # download
put local_file        # upload
get -r remote_folder  # download folder
mget *.csv            # download multiple files
bye                   # exit
```

---

## Windows

- **FileZilla**: SFTP client (GUI). Use the SFTP protocol (not FTP). Avoid the "sponsored" installer from the FileZilla website — download directly from https://filezilla-project.org.
- **WinSCP**: alternative GUI client, also supports rsync-like synchronization.
- **Windows Subsystem for Linux (WSL)**: gives you a full Linux shell with native `rsync` and `scp`.

---

## Transferring between clusters

Data is not shared between Baobab, Yggdrasil, and Bamboo. To move data between clusters, run `rsync` from one cluster's login node to the other — faster than routing through your laptop:

```bash
# From inside Baobab (after ssh baobab):
rsync -avzP ~/myproject/ login1.yggdrasil.hpc.unige.ch:~/myproject/
```

This uses the high-bandwidth inter-datacenter link instead of your local network.

---

## Large file transfers to collaborators (SWITCHfilesender)

For sending files to people outside your cluster (browser download):

```bash
# Setup (one-time): register at https://filesender.switch.ch, create API key
mkdir ~/.filesender
wget https://filesender.switch.ch/clidownload.php -O filesender.py
wget "https://filesender.switch.ch/clidownload.php?config=1" -O ~/.filesender/filesender.py.ini
# Edit ~/.filesender/filesender.py.ini: add your email and API key

# Upload and share
module load GCC Python
python3 filesender.py -p -r recipient@example.com myfile.tar.gz
# → recipient gets an email with a download link
```

---

## Tips

- **Compress before transferring** large collections of small files:
  ```bash
  tar czf results.tar.gz results/
  scp results.tar.gz baobab:~/
  ```
- **Check transfer speed** with `-P` (rsync) or `pv` (pipe viewer)
- **Avoid `find` and `ls -R`** on BeeGFS shared storage — metadata operations are slow and affect other users
- **Don't transfer to/from `/scratch`** (local node scratch) — it's only accessible from that specific node while your job runs. Use `$HOME` or `$HOME/scratch` as transfer endpoints.
