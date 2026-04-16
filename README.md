# hpc-unige

Personal reference docs for the [UNIGE HPC clusters](https://doc.eresearch.unige.ch/hpc/start) — because reading 200 pages of official documentation every time you forget an rsync flag is not a good use of your one life.

---

## 🗺️ What's in here

```
hpc-unige/
├── guides/          — Generic how-to docs (SSH, file transfer, Slurm)
└── wiki/            — LLM-maintained wiki, ingested from official UNIGE docs
    ├── _raw_/       — Source documents (immutable)
    ├── _schema_/    — Wiki operating rules
    ├── _wiki_/      — Generated content pages
    ├── index.md     — Page catalog
    └── log.md       — Ingest/update history
```

**guides/** contains polished, generic instructions that should work for any UNIGE HPC user. They don't include personal usernames or paths — those belong in your own local notes.

**wiki/** is an [LM-maintained knowledge base](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (as introduced by Andrej Karpathy) synthesized from the official UNIGE HPC documentation. It's meant to be queried and extended incrementally, not read cover to cover. Having it around will increase the accuracy of responses you get from LLMs, you don't have to read what is in it yourself.

---

## 🚀 Getting started

If you're new to the clusters, read these in order:

1. [SSH setup](guides/ssh.md) — how to connect, set up SSH keys, configure aliases, and not get locked out by fail2ban
2. [File transfer](guides/file-transfer.md) — scp, rsync, sftp, and how to move data between clusters without routing everything through your laptop
3. [Running jobs (Slurm)](guides/slurm-jobs.md) — how to actually run computations: `sbatch`, `srun`, `salloc`, picking a partition, sizing resources, monitoring jobs

Then browse the wiki for deeper dives:

| Topic | Page |
|-------|------|
| Cluster overview & architecture | [wiki/\_wiki\_/overview.md](wiki/_wiki_/overview.md) |
| Slurm job submission | [wiki/\_wiki\_/slurm.md](wiki/_wiki_/slurm.md) |
| Storage tiers & quotas | [wiki/\_wiki\_/storage.md](wiki/_wiki_/storage.md) |
| Loading software (modules, conda, containers) | [wiki/\_wiki\_/software-modules.md](wiki/_wiki_/software-modules.md) |
| Billing & accounting | [wiki/\_wiki\_/cost-and-accounting.md](wiki/_wiki_/cost-and-accounting.md) |
| Best practices (don't be that person on the login node) | [wiki/\_wiki\_/best-practices.md](wiki/_wiki_/best-practices.md) |

---

## 🖥️ The three clusters

UNIGE runs three separate HPC clusters. They do **not** share storage — pick one and stay there.

| Cluster | Location | Public GPUs | Good for |
|---------|----------|-------------|---------|
| **Baobab** | Uni Dufour | None (private only) | CPU jobs, teaching, OpenOnDemand |
| **Yggdrasil** | Astro/Sauverny | Yes (V100, Titan RTX) | GPU jobs, astrophysics |
| **Bamboo** | Campus Biotech | Yes (H100, H200, RTX 5090) | Modern GPU workloads |

All three use Slurm for job scheduling and BeeGFS for shared storage.

---

## ⚡ The five things you must not forget

1. **Never run compute jobs on the login node.** Use `sbatch` or `srun`. The login node has 2 cores and 8 GB RAM per user — it's for editing files, not crunching numbers.
2. **Scratch is not backed up.** `$HOME` gets daily backups; `$HOME/scratch` does not. Don't keep anything irreplaceable there.
3. **Scratch auto-deletes after 3 months of inactivity.** Access a file to reset the clock. Or better yet, move finished results off the cluster.
4. **Always pin software versions.** `module load Python` will load whatever is current today — which may not be what it loads in six months. Use `module load Python/3.11.3-GCCcore-12.3.0`.
5. **`find` and `du` on BeeGFS are slow and rude.** Metadata operations on the shared filesystem affect everyone. Use `lfs find` or cluster-provided tools instead.

---

## 📚 Official resources

- **Documentation**: https://doc.eresearch.unige.ch/hpc/start
- **Account request**: https://catalogue-si.unige.ch/en/hpc
- **Support**: hpc@unige.ch
- **Community forum**: https://hpc-community.unige.ch
- **Cluster status**: https://monitor.hpc.unige.ch/dashboards

---

## 🔧 Maintaining the wiki

The wiki is designed to grow incrementally. To add new sources:

1. Drop a file (PDF, markdown, plain text) into `wiki/_raw_/`
2. Ask an LLM to ingest it: *"Ingest `wiki/_raw_/<filename>` into the wiki"*
3. The LLM reads `wiki/_schema_/SCHEMA.md`, creates or updates pages in `wiki/_wiki_/`, updates `wiki/index.md`, and appends to `wiki/log.md`

See [wiki/README.md](wiki/README.md) for the full wiki workflow.

---

## 🤝 Collaboration

Feel free to contact us or create a pull request if you want to contribute to this project and provide a service to your fellow researchers in this university. Even if you just have an abstract idea of what you would like to see implemented just reach out.
