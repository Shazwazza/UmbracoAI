---
name: umb-backup
description: Back up the Umbraco LocalDB database before making changes. Use before any destructive or bulk Umbraco MCP operations.
---

# Back up the Umbraco LocalDB database

Create a timestamped backup of the Umbraco LocalDB database before proceeding with any Umbraco MCP operations.

## Steps

1. Generate a timestamp string in `yyyyMMdd-HHmmss` format.
2. Create a backup directory at `src/MyProject/umbraco/Data/backups/<timestamp>/`.
3. Find the logical database name by querying LocalDB for non-system databases:
   ```powershell
   sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SELECT name FROM sys.databases WHERE name NOT IN ('master','tempdb','model','msdb')" -h -1 -W
   ```
4. Run a T-SQL `BACKUP DATABASE` command via `sqlcmd` to create a `.bak` file in the backup directory:
   ```powershell
   $dbName = "<result from step 3>"
   $bakFile = "<backup directory>/Umbraco.bak"
   sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "BACKUP DATABASE [$dbName] TO DISK = N'$bakFile' WITH FORMAT, INIT, NAME = N'Umbraco Backup'"
   ```
5. Verify the `.bak` file exists and report the backup path and file size.

## Notes

- The `BACKUP DATABASE` command creates a consistent backup without stopping or detaching the database.
- This can safely run while the Umbraco site is running.
- The database name used by LocalDB is typically the full path to the MDF file (e.g. `C:\...\Umbraco.mdf`). Always query `sys.databases` to get the correct name rather than hardcoding it.
- `sqlcmd` must be available on the system PATH (installed with SQL Server or LocalDB tools).
- Backups are stored under `src/MyProject/umbraco/Data/backups/` which is git-ignored.
