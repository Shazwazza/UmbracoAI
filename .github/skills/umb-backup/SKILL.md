---
name: umb-backup
description: Back up the Umbraco SQLite database before making changes. Use before any destructive or bulk Umbraco MCP operations.
---

# Back up the Umbraco SQLite database

Create a timestamped backup of the Umbraco SQLite database files before proceeding with any Umbraco MCP operations.

## Steps

1. Generate a timestamp string in `yyyyMMdd-HHmmss` format.
2. Create a backup directory at `src/MyProject/umbraco/Data/backups/<timestamp>/`.
3. Copy all three SQLite files into the backup directory:
   - `src/MyProject/umbraco/Data/Umbraco.sqlite.db`
   - `src/MyProject/umbraco/Data/Umbraco.sqlite.db-wal`
   - `src/MyProject/umbraco/Data/Umbraco.sqlite.db-shm`
4. Verify the copies exist and report the backup path and file sizes.

## Notes

- The `-wal` and `-shm` files may not always exist. Copy them if present; skip without error if absent.
- Backups are stored under `src/MyProject/umbraco/Data/backups/` which is git-ignored.
- This can safely run while the Umbraco site is running.
