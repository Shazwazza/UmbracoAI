---
name: umb-reset
description: Reset all Umbraco website work back to defaults. Use when asked to clean, reset, or undo generated Umbraco site work.
---

# Undo all Umbraco work to reset to defaults

Follow the steps below in exact order. Deletion order matters — content must be removed before templates, and templates before document types.

## Step 1 — Delete all Content (Umbraco MCP)

1. Call `get-document-root` to list root documents.
2. For each document, call `move-document-to-recycle-bin` with its ID.
3. Call `empty-recycle-bin` to permanently delete all trashed documents.

## Step 2 — Delete all Media (Umbraco MCP)

1. Call `get-media-root` to list root media items.
2. For each media item, call `move-media-to-recycle-bin` with its ID.
3. Call `empty-media-recycle-bin` to permanently delete all trashed media.

## Step 3 — Delete all Templates (Umbraco MCP)

1. Call `get-template-root` to list all templates.
2. For each template, call `delete-template` with its ID.

## Step 4 — Delete all Document Types (Umbraco MCP)

1. Call `get-all-document-types` to list all document types.
2. For each document type (non-folder), call `delete-document-type` with its ID.
3. For each document type folder, call `delete-document-type-folder` with its ID.

## Step 5 — Delete all Stylesheets (Umbraco MCP)

1. Call `get-stylesheet-root` to list all stylesheets.
2. For each stylesheet, call `delete-stylesheet` with its path.

## Step 6 — Filesystem cleanup (PowerShell script)

Run the pre-built cleanup script:

```powershell
& ".github/skills/umb-reset/reset-filesystem.ps1"
```

This script:
- Deletes all files in `src/MyProject/wwwroot/css/`
- Deletes custom partial views in `src/MyProject/Views/Partials/` (preserves blockgrid/blocklist/singleblock)
- Deletes generated template `.cshtml` files in `src/MyProject/Views/` (preserves `_ViewImports.cshtml` and `_ViewStart.cshtml`)

## Step 7 — Verify

Confirm all trees are empty:
- `get-document-root` returns 0 items
- `get-media-root` returns 0 items
- `get-template-root` returns 0 items
- `get-all-document-types` returns 0 items

