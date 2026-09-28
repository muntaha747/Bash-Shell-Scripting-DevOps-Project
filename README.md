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


