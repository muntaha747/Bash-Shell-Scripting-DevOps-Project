# Bash Scripting Projects

A bunch of bash scripts I've written while learning Linux automation on my own EC2 box. Each one solves a small problem I actually ran into — cleaning up Docker junk, backing up Jenkins, installing Prometheus without downloading the same tarball three times. Nothing fancy. Just scripts I use.

---

## 📂 What's inside

| Script | What it does |
|---|---|
| [`arguments.sh`](#-argumentssh) | Shows how positional arguments and argument count work |
| [`project-01-gitinstall.sh`](#-project-01-gitinstallsh) | Installs git using the right package manager for the OS |
| [`project-02-disk-utilization.sh`](#-project-02-disk-utilizationsh) | Alerts when disk usage crosses 80% |
| [`project-03-biggestfile-infilesystem.sh`](#-project-03-biggestfile-infilesystemsh) | Lists the top 5 biggest files in a path |
| [`project-04-delete-old-log.sh`](#-project-04-delete-old-logsh) | Deletes files older than 30 days |
| [`project-05-install-prometheus.sh`](#-project-05-install-prometheussh) | Downloads and extracts Prometheus |
| [`project-06-forloop.sh`](#-project-06-forloopsh) | Loops through folders and removes test directories |
| [`project-07-docker-service-status.sh`](#-project-07-docker-service-statussh) | Checks whether Docker is running |
| [`project-08-Crontab-Docker-service.sh`](#-project-08-crontab-docker-servicesh) | Checks Docker status and starts it if it's down |
| [`project-09-Install-software-with-positional-args.sh`](#-project-09-install-software-with-positional-argssh) | Installs multiple packages from positional arguments |
| [`Project-A-Docker-Shell.sh`](#-project-a-docker-shellsh) | Docker utility shell script |
| [`Project-B-Jenkins-Script.sh`](#-project-b-jenkins-scriptsh) | Jenkins backup and management script |
---

## 🗂 jenkins_backup.sh

Backs up a Jenkins home directory, packs it into a `.tar.gz`, and uploads it to an S3 bucket. I run this nightly via cron so I have a copy of my Jenkins config somewhere other than the box itself.

### What it backs up

- Job definitions — `config.xml` and `nextBuildNumber` for every job
- Installed plugins — `.hpi` / `.jpi` files
- `users/`, `secrets/`, `nodes/`
- Root-level XMLs, including `credentials.xml`
- `logs/` and `workspace/` if they exist

### Usage

```bash
sudo ./jenkins_backup.sh /var/lib/jenkins <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>
```

### Notes

- Must run as root. The script checks and bails if you're not.
- Change the `S3_BUCKET` variable near the top to your bucket.
- Logs go to `/var/log/jenkins_backup.log`.
- Workspace backups can be **huge**. If you don't need them, comment out that block.

### Cron example

```
0 2 * * * /path/to/jenkins_backup.sh /var/lib/jenkins KEY SECRET >> /var/log/jenkins_backup_cron.log 2>&1
```

---

## 🐳 docker_cleanup.sh

Cleans up Docker cruft on a host:

- Images tagged `<none>` or `latest`
- Stopped containers
- Images older than ~2 months
- Dangling images and dangling volumes

Has a `--dry-run` flag so you can preview before deleting anything.

```bash
sudo ./docker_cleanup.sh --dry-run    # preview
sudo ./docker_cleanup.sh              # actually delete
```

> ⚠️ The `docker images | grep` based checks are fragile — image output format changes between Docker versions. Always test with `--dry-run` first.

---

## 🧰 install_git.sh

Installs git using whichever package manager is available on the box.

```bash
sudo ./install_git.sh
```

Detects:
- `apt` → Debian / Ubuntu
- `dnf` → RHEL / Fedora / Rocky / Alma
- `brew` → macOS

If none are found, it exits without doing anything.

---

## 📈 install_prometheus.sh

Downloads the Prometheus tarball from GitHub and extracts it. Safe to run multiple times — if the folder or tarball already exists, it skips the download step.

```bash
./install_prometheus.sh
```

Version and paths are hardcoded at the top:

```bash
TAR_FILE="/home/ubuntu/prometheus-3.15.0.linux-amd64.tar.gz"
EXTRACTED_FILE="/home/ubuntu/prometheus-3.15.0.linux-amd64"
```

Change those for a different version or user.

### Running `prometheus` from anywhere

After extraction, add the folder to your `$PATH`:

```bash
echo 'export PATH="$PATH:/home/ubuntu/prometheus-3.15.0.linux-amd64"' >> ~/.bashrc
source ~/.bashrc
```

Now `prometheus` works from any directory.

---

## 💾 disk_usage.sh

Checks disk usage on the main partition and warns if it crosses 80%.

```bash
./disk_usage.sh
```

Output:
```
65% of the disk is filled
Enough disk space is available
```
or
```
92% of the disk is filled
Disk is utilized more than 80%, expand the existing disk or delete some files
```

> **Note:** The partition `/dev/nvme0n1p13` is hardcoded for my EC2 setup. Change it to match your system — run `df -h` to find your partition name.

---

## 📊 biggest_files.sh

Lists the 5 biggest files or folders under a given path.

```bash
./biggest_files.sh /var/log
```

Writes the results to `/tmp/filesize.txt` and prints them. Useful when a disk is filling up and you don't know where the space went.

---

## 🗑 delete_old_files.sh

Deletes files older than 30 days under a given path.

```bash
./delete_old_files.sh /var/log/myapp
```

> ⚠️ This uses `find -mtime +30 -delete`. There is no undo. Test with `find <path> -mtime +30` first to see what would be deleted.

---

## 🛠 General notes

Most scripts use `set -euo pipefail`:

| Flag | What it does |
|---|---|
| `-e` | Exit on any command failure |
| `-u` | Error on unset variables |
| `-o pipefail` | A pipeline fails if any stage fails |

This stops the script at the first sign of trouble instead of continuing and doing damage.

**About credentials:** `jenkins_backup.sh` takes AWS keys on the command line. Convenient for testing, but they show up in `ps` output and shell history. On a real EC2 instance, use an IAM instance role and remove the credential arguments.

**Tested on:** Ubuntu 22.04 on EC2. Some scripts have hardcoded paths that will need editing for other setups.

---

## 🚀 Setup

```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
chmod +x *.sh
```

Run any script with:

```bash
sudo ./scriptname.sh
```

unless noted otherwise in its section above.

---

