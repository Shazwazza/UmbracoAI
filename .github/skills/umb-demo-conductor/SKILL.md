---
name: umb-demo-conductor
description: Run the end-to-end Umbraco blogging-site demo as a Conductor multi-agent workflow. Use when asked to build the full demo site via Conductor (the orchestrated, workflow-driven variant of the umbraco-demo agent).
---

# Run the Umbraco demo as a Conductor workflow

This skill runs the complete Umbraco blogging-site demo as a
[Conductor](https://github.com/github/conductor) multi-agent workflow. The
workflow file lives next to this skill at
[`umbraco-demo.yaml`](./umbraco-demo.yaml) and embeds most demo steps by
`!file`-including their `SKILL.md` (`umb-homepage`, `umb-blog-pages`,
`umb-navigation`, `umb-image-sourcing`, `umb-blogpost-images`, `umb-tagcloud`,
`umb-sitemap`, `umb-accessibility`), plus an optional backup/reset and a branch
setup step. The blog-posts step is purpose-built inline to showcase Conductor:
a deterministic **plan** agent emits a typed post contract, a **`for_each`
fan-out** authors every post body concurrently, then a serial **join** agent
persists them to Umbraco one at a time (content writes must stay sequential).

## ⚠️ Critical browser rule

The Playwright browser window is projected live to the audience. The workflow
opens it ONCE (in the home-page step) and reuses it for the whole run. NEVER
close the browser at any point.

## Prerequisites

1. **Start the Conductor's Playwright MCP server FIRST.** The Conductor workflow
   connects to a headed Playwright server over HTTP on **port 8932**, separate
   from the traditional demo agent's server (port 8931). This gives the workflow
   its **own** visible browser window, so it can run at the same time as the
   traditional demo agent without sharing a window. From the repo root:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1 -Port 8932
   ```
   This launches a detached, headed `@playwright/mcp` server with
   `--shared-browser-context` on `http://localhost:8932/mcp` (and a per-port
   browser profile). It is idempotent (reuses an already-running server) and
   detached (the browser stays open after the run). The workflow's `playwright`
   MCP server points at this `http://localhost:8932/mcp` endpoint. (The
   traditional demo agent uses the port-8931 server from `.mcp.json`; if you are
   only running the Conductor flow you still use 8932 here.)
2. The Umbraco site must be running at `CONDUCTOR_SITE_BASE_URL` (see Project
   Configuration in `copilot-instructions.md`). This is the dedicated Conductor
   environment site (separate database from the traditional demo site, so both
   can run at once). If not running, start it with:
   `dotnet run --project src/MyProject/MyProject.csproj --launch-profile Conductor -p:SiteEnv=Conductor`.
3. The `conductor` CLI must be installed. Check with `conductor --version`.
   - If it is missing, install it per the Conductor skill's setup guide
     (`/.copilot/installed-plugins/conductor/.../references/setup.md`).

### Launch order (important)

1. `scripts/start-playwright-mcp.ps1 -Port 8932` — start the Conductor's headed browser server.
2. Start the Copilot CLI session — it connects to the server via HTTP.
3. Run the conductor workflow (below) — it connects to the port-8932 server, so
   every step drives the Conductor's own visible window (separate from the
   traditional demo agent's port-8931 window).

## Running the workflow

Run from the repository root so that the MCP servers and `--workspace-instructions`
auto-discovery resolve correctly. **Always pass `--web`** so the live dashboard
(DAG graph, agent streaming, gate nodes) is visible to the audience:

```bash
conductor run .github/skills/umb-demo-conductor/umbraco-demo.yaml --workspace-instructions --web --skip-gates --no-interactive
```

- `--web` opens the real-time dashboard (DAG graph, live streaming, gate nodes).
  This is required for this demo — we always want to watch the workflow in the
  browser. After launch, open the printed `Dashboard:` URL in a browser window.
- `--skip-gates` auto-selects the first option at the human gate, which is
  *"Yes — back up and reset to a clean slate first"* — the correct default for a
  fresh demo build. This flag is needed because the agent launches the command
  **non-interactively** (no TTY): Conductor v0.1.18 cannot yet resolve a human
  gate from the browser, so a plain foreground `--web` run blocks on terminal
  stdin and fails with `EOFError`, and `--web-bg` is rejected outright when a
  `human_gate` is present. The gate node still appears in the dashboard.
- `--no-interactive` disables the Esc/Ctrl+G interrupt listener so the
  non-interactive process never blocks on stdin.
- If you DO have an interactive terminal and want to answer the gate yourself,
  run `... --web` without `--skip-gates --no-interactive` and select the option
  at the terminal prompt.
- `--workspace-instructions` layers in the full repository rules at run time
  (`.github/copilot-instructions.md` and the applicable
  `.github/instructions/**/*.instructions.md` files), so the workflow does not
  duplicate them.
- The workflow defines its own MCP servers (`umbraco-mcp`, `playwright`,
  `a11y-accessibility`) mirroring `.mcp.json`. `playwright` is configured as an
  HTTP server pointing at the Conductor's headed browser started in the
  Prerequisites (`http://localhost:8932/mcp`), so the workflow drives its own
  browser window — separate from the traditional demo agent's port-8931 window —
  and that single window persists across every step. `umbraco-mcp` and
  `a11y-accessibility` remain stdio.
- Override the site URL if needed (defaults to `CONDUCTOR_SITE_BASE_URL`, see
  Project Configuration in copilot-instructions.md):
  `--input site_base_url=<CONDUCTOR_SITE_BASE_URL>`.

### Human gate (reset prompt)

The first step is a **human gate** asking whether to back up and reset the site
to a clean slate before building. The recommended hands-off command above passes
`--skip-gates`, which auto-selects the first option (*"Yes — back up and reset"*)
— the right choice for a fresh demo build — while the gate node remains visible
in the `--web` dashboard. To answer the gate manually instead, run with `--web`
in an interactive terminal (without `--skip-gates --no-interactive`) and pick the
option at the prompt.

## Validating without running

To check the workflow without executing it:

```bash
conductor validate .github/skills/umb-demo-conductor/umbraco-demo.yaml
conductor show .github/skills/umb-demo-conductor/umbraco-demo.yaml
```

## Error handling

> **Do NOT improvise workarounds.** If `conductor` fails for any reason
> (installation failure, provider error, missing dependency, MCP server failure),
> report the **exact error message** to the user and stop. Do not attempt to
> simulate or replicate the multi-agent workflow by hand — the value of this
> skill is the orchestrated, multi-agent run. Likewise, if an Umbraco MCP tool
> is unavailable or failing, stop and notify the user rather than substituting a
> direct API call.
