---
name: umb-demo-conductor
description: Run the end-to-end Umbraco blogging-site demo as a Conductor multi-agent workflow. Use when asked to build the full demo site via Conductor (the orchestrated, workflow-driven variant of the umbraco-demo agent).
---

# Run the Umbraco demo as a Conductor workflow

This skill runs the complete 8-step Umbraco blogging-site demo as a
[Conductor](https://github.com/github/conductor) multi-agent workflow. The
workflow file lives next to this skill at
[`umbraco-demo.yaml`](./umbraco-demo.yaml) and embeds each existing demo step by
`!file`-including its `SKILL.md` (`umb-homepage`, `umb-blog-pages`,
`umb-navigation`, `umb-blogposts`, `umb-blogpost-images`, `umb-tagcloud`,
`umb-sitemap`, `umb-accessibility`), plus an optional backup/reset and a branch
setup step.

## ⚠️ Critical browser rule

The Playwright browser window is projected live to the audience. The workflow
opens it ONCE (in the home-page step) and reuses it for the whole run. NEVER
close the browser at any point.

## Prerequisites

1. The Umbraco site must be running at `SITE_BASE_URL` (see Project
   Configuration in `copilot-instructions.md`). If not, start it with:
   `dotnet run --project src/MyProject/MyProject.csproj`.
2. The `conductor` CLI must be installed. Check with `conductor --version`.
   - If it is missing, install it per the Conductor skill's setup guide
     (`/.copilot/installed-plugins/conductor/.../references/setup.md`).

## Running the workflow

Run from the repository root so that the MCP servers and `--workspace-instructions`
auto-discovery resolve correctly. **Always pass `--web`** so the run and any
human-in-the-loop gates are visible in the live dashboard:

```bash
conductor run .github/skills/umb-demo-conductor/umbraco-demo.yaml --workspace-instructions --web
```

- `--web` opens the real-time dashboard (DAG graph, live streaming, in-browser
  human gates). This is required for this demo — we always want to watch the
  workflow and handle gates in the browser. Use `--web-bg` only if you need the
  command to print the dashboard URL and return immediately.
- `--workspace-instructions` layers in the full repository rules at run time
  (`.github/copilot-instructions.md` and the applicable
  `.github/instructions/**/*.instructions.md` files), so the workflow does not
  duplicate them.
- The workflow defines its own MCP servers (`umbraco-mcp`, `playwright`,
  `a11y-accessibility`) mirroring `.mcp.json`, so the browser and Umbraco
  connection persist across every step.
- Override the site URL if needed:
  `--input site_base_url=http://localhost:14737`.

### Human gate (reset prompt)

The first step is a **human gate** asking whether to back up and reset the site
to a clean slate before building. With `--web` (always used here), answer the
gate directly in the dashboard in your browser.

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

## What the workflow does

1. **Human gate** — optionally back up (`umb-backup`) and reset (`umb-reset`).
2. **Step 0 — Branch setup** — ensure work is on a `develop/*` branch.
3. **Step 1 — Home page** (`umb-homepage`) — opens the browser on the empty
   site first, then builds the home page with a fresh visual identity.
4. **Step 2 — Blog pages** (`umb-blog-pages`).
5. **Step 3 — Navigation** (`umb-navigation`).
6. **Step 4 — Blog posts** (`umb-blogposts`).
7. **Step 5 — Blog post images** (`umb-blogpost-images`).
8. **Step 6 — Tag cloud** (`umb-tagcloud`).
9. **Step 7 — Sitemap** (`umb-sitemap`).
10. **Step 8 — Accessibility** (`umb-accessibility`).
11. **Final** — whole-site validation in Playwright and a written summary; the
    browser is left open on the finished site.

Each step validates its page renders (no `#stackpage` error div) and makes its
own git commit before the next step begins.
