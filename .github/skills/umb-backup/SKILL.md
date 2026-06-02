---
name: umb-backup
description: Back up the Umbraco LocalDB database before making changes. Use before any destructive or bulk Umbraco MCP operations.
---

# Back up the Umbraco LocalDB database

Run the pre-built backup script:

```powershell
& ".github/skills/umb-backup/backup-database.ps1"
```

The script will:
1. Generate a timestamp and create a backup directory at `src/MyProject/umbraco/Data/backups/<timestamp>/`.
2. Query LocalDB for the Umbraco database name.
3. Run `BACKUP DATABASE` via `sqlcmd` to create a `.bak` file.
4. Verify the backup file exists and report the path and size.

## Notes

- The backup runs without stopping or detaching the database — safe while the site is running.
- `sqlcmd` must be available on the system PATH (installed with SQL Server or LocalDB tools).
- Backups are stored under `src/MyProject/umbraco/Data/backups/` which is git-ignored.
