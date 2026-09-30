# Bash-Shell-Scripting-DevOps-Project
# Docker Cleanup Script

##################################################################################################################################################
PROJECT01
##################################################################################################################################################

noneimages=$($DOCKER images -f "reference=*:latest" -q)  #$($DOCKER images | grep -w "<none>" | awk '{print $2}')
A Bash script that cleans up unused Docker data on an Ubuntu machine. It removes old images, stopped containers, and unused volumes to free up disk space.

It has a **dry-run mode** so you can see what would be deleted before anything is actually removed.

---

## What it cleans

The script runs these five checks, in this order:

| # | What it looks for | What it does |
|---|-------------------|--------------|
| 1 | Images tagged `latest` | Deletes them |
| 2 | Stopped containers (status `Exited`) | Deletes them |
| 3 | Images that are 5+ weeks, months, or years old | Deletes them |
| 4 | Dangling images (untagged, shown as `<none>`) | Deletes them |
| 5 | Dangling volumes (not used by any container) | Deletes them |

---

## Requirements

- Ubuntu (or any Linux with Bash)
- Docker installed at `/usr/bin/docker`
- Permission to run Docker commands (your user should be in the `docker` group, or run with `sudo`)

To check where Docker is on your machine:

```bash
which docker
```

If it prints something other than `/usr/bin/docker`, change the `DOCKER=` line at the top of the script.

---

## How to use

Make the script executable (one time only):

```bash
chmod +x Docker-Shell.sh
```

**Dry run (safe mode).** Shows what would be deleted and deletes nothing:

```bash
./Docker-Shell.sh --dry-run
```

**Real run.** Actually deletes things:

```bash
./Docker-Shell.sh
```

**Help:**

```bash
./Docker-Shell.sh -h
```

Always run `--dry-run` first.

---

## Options

| Option | What it does |
|--------|--------------|
| `--dry-run` or `-dry-run` | Only lists what would be deleted |
| `-h` or `--h` | Shows the help message |
| anything else | Prints "Invalid option" and stops |

---

## How the script works

1. **Validation step.** A `while` loop reads each option you typed. `--dry-run` sets `DRYRUN=1`. Any unknown option stops the script. `shift` moves to the next option until none are left.
2. **Each cleanup section** builds a list of IDs using Docker's own filters, then loops over the list. If `DRYRUN` is `0`, it deletes each item and checks `$?` to report success or failure. If the list is empty, it prints a "nothing to delete" message.

Docker commands used:

```bash
docker images -f "reference=*:latest" -q     # images tagged latest
docker ps -a                                 # stopped containers
docker images --format "{{.ID}} {{.CreatedSince}}"   # image age
docker images -qf dangling=true              # untagged images
docker volume ls -qf dangling=true           # unused volumes
```

---

## Warnings (please read)

This script **deletes data**. Know what it removes before running it for real.

- **Volumes can hold your data.** Dangling volumes include named ones, such as database volumes (for example `django-notes-app_mysql-data`). A volume with no container attached is not always safe to delete. Once deleted, the data is gone.
- **All `latest` images are removed**, even ones you still want.
- **Old images are removed** if they are 5+ weeks old, even if you still use them.
- **`rmi -f` and `rm -f` force the delete.** Forced deletes can remove images that stopped containers still depend on.

Recommended: run `--dry-run`, read the list carefully, then decide.

---

## Example output

Dry run with nothing to clean:

```
== No docker Images to be deleted
There is nothing to remove from your system
====No older image is found
== No Docker dangling Images to delete ==
=====No dangling volumes found
```

---

## Known limitations

- In dry-run mode, the script prints only the ID, not a "would delete" message.
- Docker has no built-in dry run for these commands, so dry-run mode only lists IDs.
- Some `echo` messages use `\n` without `-e`, so they may print a literal `\n`.
- Only tested with the Docker CLI on Ubuntu.

---

## Project structure

```
.
├── Docker-Shell.sh    # the cleanup script
└── README.md          # this file
```




##################################################################################################################################################
PROJECT02
##################################################################################################################################################


# Jenkins Backup Script

A bash script I wrote to back up my Jenkins server to S3. It grabs the important stuff from `/var/lib/jenkins`, packs it into a `.tar.gz`, and pushes it to an S3 bucket. Runs on a schedule via cron.

## Why I wrote this

Jenkins doesn't ship with a great backup story. The ThinBackup plugin exists but I wanted something I could read top-to-bottom and modify without fighting a UI. So this is a plain bash script — you can open it, read it, change it, and know exactly what it does.

It backs up:
- Job definitions (`config.xml` and `nextBuildNumber` for each job — not the build history)
- Installed plugins (`.hpi` and `.jpi` files)
- Users (config, API tokens, SSH keys)
- Secrets (the encryption keys — needed to decrypt credentials later)
- Nodes (build agent configs)
- Root-level XMLs, including `credentials.xml`
- Logs and workspaces (optional — see the note below)

## Before you run it

You need:
- Root access (the script checks for this and bails if you're not root)
- AWS CLI installed and working (`aws --version`)
- An S3 bucket to upload to
- AWS credentials with `s3:PutObject` on that bucket

## Setup

1. Create the bucket if you don't have one:
   ```bash
   aws s3 mb s3://your-bucket-name
   ```

2. Clone the repo and make the script executable:
   ```bash
   git clone https://github.com/<your-username>/jenkins-backup.git
   cd jenkins-backup
   chmod +x jenkins_backup.sh
   ```

3. Open `jenkins_backup.sh` and change the bucket name near the top:
   ```bash
   S3_BUCKET="jenkins-metadata-backup"
   ```

## Running it

```bash
sudo ./jenkins_backup.sh /var/lib/jenkins AKIA... yourSecretKey
```

Three arguments:
- Path to your Jenkins home (usually `/var/lib/jenkins`)
- AWS access key ID
- AWS secret access key

If you get the arguments wrong, it prints the usage line and exits.

## What it actually does

Simple flow, in order:

1. Checks you're root, and that you passed 3 arguments
2. Deletes any leftover staging folder and tar file from a previous run
3. Creates `/tmp/jenkins-backup/` with subfolders: `plugins`, `jobs`, `secrets`, `logs`, `workspace`, `nodes`
4. Copies root `*.xml` files into staging
5. Copies plugin files (`*.hpi`, `*.jpi`)
6. Copies users, secrets, logs, workspace, nodes — but only if the source folder has something in it
7. Copies each job's `config.xml` and `nextBuildNumber` into `staging/jobs/<jobname>/`
8. Tars the whole staging folder into `/tmp/jenkins-backup-<timestamp>.tar.gz`
9. Uploads that tar to S3
10. Deletes the staging folder
11. Logs "Backup complete" and exits

## The workspace folder

By default the script includes `workspace/`. Fair warning: on a busy Jenkins this can be **tens of gigabytes**. If you don't need it (and most people don't — workspaces are rebuilt from source anyway), comment out or delete these lines in the script:

```bash
if [ -n "$(ls -A "${JENKINS_PATH}/workspace/" 2>/dev/null)" ]; then
    cp -R "${JENKINS_PATH}/workspace/"* "${STAGING_DIR}/workspace/" 2>/dev/null || true
fi
```

Or leave it in and set up an S3 lifecycle rule to expire old backups.

## Logs

Everything gets written to `/var/log/jenkins_backup.log`. Format is simple:

```
2026-09-29 14:30:01 - Created archive /tmp/jenkins-backup-2026-09-29_14-30-00.tar.gz
2026-09-29 14:30:03 - Uploaded jenkins-backup-2026-09-29_14-30-00.tar.gz to s3://jenkins-metadata-backup/
```

Check it with:
```bash
sudo tail -f /var/log/jenkins_backup.log
```

## Running it on a schedule

I run this nightly with cron. To do the same:

```bash
sudo crontab -e
```

Add:

```
0 2 * * * /path/to/jenkins_backup.sh /var/lib/jenkins YOUR_KEY YOUR_SECRET >> /var/log/jenkins_backup_cron.log 2>&1
```

The `>> ... 2>&1` part captures any output (including errors) into a separate cron log, so if something goes wrong you have a record of it.

## Restoring

The script only makes backups — restoring is manual. Steps:

```bash
# Pull the archive down
aws s3 cp s3://your-bucket-name/jenkins-backup-2026-09-29_14-30-00.tar.gz /tmp/

# Stop Jenkins
sudo systemctl stop jenkins

# Extract
cd /tmp
tar -xzf jenkins-backup-2026-09-29_14-30-00.tar.gz

# Copy into Jenkins home
sudo cp -R /tmp/jenkins-backup/* /var/lib/jenkins/

# Fix permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins

# Start Jenkins
sudo systemctl start jenkins
```

Test the restore path at least once before you need it. A backup you've never restored isn't a backup.

## A note on security

This script uploads some sensitive stuff:

- `credentials.xml` (encrypted credentials, but still — treat it carefully)
- `secrets/` (the master encryption keys)
- `users/` (API tokens, SSH keys)

A few things I'd recommend:

- Turn on S3 encryption (SSE-S3 is easy, SSE-KMS is better)
- Lock the bucket down so only your backup user can read/write to it
- Enable versioning so an accidental overwrite doesn't destroy the last good backup
- Set a lifecycle rule to delete old backups after a reasonable time
- Never commit your AWS keys to Git — pass them on the command line, or better, use an IAM role if you're on EC2

## Things that might go wrong

| What you see | What it means |
|---|---|
| `Please run this script as root` | You forgot `sudo` |
| `Usage: ...` | You didn't pass all 3 arguments |
| `aws: command not found` | AWS CLI isn't installed |
| `Unable to locate credentials` | Keys are wrong or not exported |
| `Access Denied` from S3 | Your IAM user can't write to the bucket |

