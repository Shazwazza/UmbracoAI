# Umbraco and Copilot CLI

Prompting, rules and instructions for facilitating Umbraco management via Copilot CLI, MCP, and AI Agents.

## Umbraco Codegarden 2026

This project was put together as a presentation for the Umbraco Codegarden 2026 conference to showcase how custom rules and commands can be stored in a git repository so they can be re-used for Umbraco management.

In this demo, the premise is to have an AI Agent automatically create an Umbraco Blogging website from scratch.

## Quick Start

`TLDR;`

1. Install Playwright as admin with `npx playwright install`
1. Clone/Fork this repo and open in your Copilot-enabled editor.
1. The Umbraco website needs to be running/installed: `dotnet run --project src/MyProject/MyProject.csproj --launch-profile Umbraco.Web.UI -p:SiteEnv=Development`
1. Configure MCP servers in `/.mcp.json`
1. [Create an Umbraco API User](https://docs.umbraco.com/umbraco-cms/fundamentals/data/users/api-users), with credentials matching `/.mcp.json`
1. Start Copilot CLI and run the end-to-end demo with `Use the umbraco-demo agent`
1. Or run individual skills such as `/umb-homepage`, `/umb-blog-pages`, and `/umb-navigation`

![Demo](Step01.gif)

👇👇👇👇👇👇

![alt text](image-2.png)

## Using this repo

### Copilot CLI

This repository is configured for **Copilot CLI**:

* Shared instructions: `/.github/copilot-instructions.md`
* Modular instructions: `/.github/instructions/*.instructions.md`
* Reusable skills: `/.github/skills/*/SKILL.md`
* Agents: `/.github/agents/*.agent.md`
* MCP servers: `/.mcp.json`

### Copilot CLI plugin + marketplace

This repo now includes a first-class Copilot CLI plugin and marketplace manifests:

* Plugin manifest: `/.github/plugin/plugin.json`
* Marketplace manifest: `/.github/plugin/marketplace.json`

Install the plugin directly from this repository:

```bash
copilot plugin install Shazwazza/UmbracoAI
```

Or register this repository as a marketplace, then install the `umbracoai-demo` plugin from the `umbracoai-marketplace` marketplace:

```bash
copilot plugin marketplace add Shazwazza/UmbracoAI
copilot plugin install umbracoai-demo@umbracoai-marketplace
```

### Umbraco website & Umbraco MCP

1. The Umbraco website will need to be run/installed first: `dotnet run --project src/MyProject/MyProject.csproj --launch-profile Umbraco.Web.UI -p:SiteEnv=Development`
1. Read and configure Umbraco MCP: https://github.com/umbraco/Umbraco-CMS-MCP-Dev including the user information.
1. Edit `/.mcp.json` to update your Umbraco settings.
1. NOTE: ALL Umbraco MCP commands are marked as 'always allow', however there is this filter applied to the MCP server: "UMBRACO_INCLUDE_TOOL_COLLECTIONS": "document,media,document-type,data-type".

### Running two sites at once

For a live demo you may want to run the **traditional demo agent** and the
**Conductor workflow** simultaneously. They each need their own Umbraco site and
database, so the project ships with two environments / launch profiles:

| Site | Env / launch profile | URL | LocalDB database | Driven by |
|------|----------------------|-----|------------------|-----------|
| Traditional demo | `Development` / `Umbraco.Web.UI` | `http://localhost:14737` | `Umbraco.mdf` | Copilot CLI (`/.mcp.json`) |
| Conductor workflow | `Conductor` / `Conductor` | `http://localhost:14738` | `UmbracoConductor.mdf` | Workflow (`umbraco-demo.yaml`) |

Start each one in its own terminal from the repo root:

```bash
# Terminal 1 — traditional demo site
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Umbraco.Web.UI -p:SiteEnv=Development

# Terminal 2 — Conductor workflow site
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Conductor -p:SiteEnv=Conductor
```

How it works:

* Each profile sets `ASPNETCORE_ENVIRONMENT`, so the second site loads
  `src/MyProject/appsettings.Conductor.json`, which points `umbracoDbDSN` at a
  separate LocalDB database (`UmbracoConductor.mdf`).
* The `-p:SiteEnv=...` global property redirects each site's build output to
  `bin\<SiteEnv>\` / `obj\<SiteEnv>\` (see `src/MyProject/Directory.Build.props`),
  so the two builds never lock each other's `MyProject.exe`. It MUST be passed on
  the command line because launch-profile environment variables do not reach the
  build phase of `dotnet run`.
* The second site uses `LocalTempStorageLocation: EnvironmentTemp` with a unique
  `SiteName`, so its Examine indexes and content cache live in a separate temp
  folder and do not clash with the default site.
* The traditional flow uses `/.mcp.json` (`UMBRACO_BASE_URL=http://localhost:14737`);
  the Conductor workflow uses the `umbraco-demo.yaml` MCP config
  (`UMBRACO_BASE_URL=http://localhost:14738`).

**One-time setup per site:** each database must be installed once (run the site and
complete the Umbraco installer) and have the Umbraco API user created with the
credentials in `/.mcp.json` (traditional) and `umbraco-demo.yaml` (Conductor).
You only need the second site if you intend to run the Conductor workflow; running
just the traditional demo only needs the default `Umbraco.Web.UI` profile.

> **Two browser windows:** each flow uses its own Playwright MCP server so the
> two demos show in **separate** visible browser windows running at the same time:
> the traditional demo agent uses `http://localhost:8931/mcp` (from `/.mcp.json`)
> and the Conductor workflow uses `http://localhost:8932/mcp` (from
> `umbraco-demo.yaml`). Start one server per window (the browser profile is
> per-port, so they don't clash):
>
> ```powershell
> # Window 1 — traditional demo agent (port 8931, the default)
> powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1
> # Window 2 — Conductor workflow (port 8932)
> powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1 -Port 8932
> ```

### "YOLO mode"

Part of the presentation was to showcase that an AI Agent can autonomously do all of the work without user interaction once the rules and skills are setup. As such, several MCP tools are pre-installed in `/.mcp.json` with 'always allow' configured.

![YOLO Tools](image-3.png)

For this demo, other cmd line tools have been auto-allowed:

![YOLO cmd line](image.png)

### USync

USync has been installed to this website in order to track schema and content changes in Git. This allows you to rollback/forward any changes that the Agent makes.

## End-to-end demo agent

For a single-command, fully automated demo run the `umbraco-demo` agent:

```
Use the umbraco-demo agent to build the full Umbraco blogging site
```

The agent will:
1. Ask whether to reset the site first
2. Run each skill below in sequence
3. Validate each step with Playwright before moving on
4. Summarise what was built when complete

The `umbraco-demo` agent profile lives at `/.github/agents/umbraco-demo.agent.md` and is auto-discovered by Copilot CLI.

### Conductor workflow variant

The same end-to-end demo can also be run as a [Conductor](https://github.com/github/conductor) multi-agent workflow. The `umbraco-demo-conductor` agent calls the `/umb-demo-conductor` skill, which runs the workflow defined at `/.github/skills/umb-demo-conductor/umbraco-demo.yaml`. That workflow embeds each demo step by including its existing `SKILL.md`, with a human gate for the optional reset, a branch-setup step, and a final summary:

```
Use the umbraco-demo-conductor agent to build the full Umbraco blogging site
```

The Conductor workflow runs against its **own** Umbraco site (the `Conductor` launch profile / environment at `http://localhost:14738`) so it can run at the same time as the traditional demo agent without sharing a database — see [Running two sites at once](#running-two-sites-at-once). Start it with:

```
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Conductor -p:SiteEnv=Conductor
```

**Before running, start the Conductor's Playwright browser server (port 8932)** so the workflow drives its *own* visible window — separate from the traditional demo agent's port-8931 window, so both can run at once (otherwise later steps run in a hidden browser). From the repo root, in this order:

```powershell
# 1. Start the Conductor's headed Playwright MCP server on port 8932 (detached, idempotent)
powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1 -Port 8932
# 2. Start your Copilot CLI session (it reads .mcp.json -> connects over HTTP)
# 3. Run the workflow (connects to the port-8932 server)
```

The workflow points its `playwright` MCP server at `http://localhost:8932/mcp`, while `.mcp.json` (the traditional demo agent) points at `http://localhost:8931/mcp` — two separate headed `@playwright/mcp` instances launched with `--shared-browser-context` and per-port profiles. Each server is detached, so the browser stays open after the run.

Or run the workflow directly from the repo root. Always pass `--web` so the live dashboard is visible; add `--skip-gates --no-interactive` for a hands-off run (auto-accepts the gate's first option — back up + reset — and avoids blocking on stdin in a non-interactive shell):

```
conductor run .github/skills/umb-demo-conductor/umbraco-demo.yaml --workspace-instructions --web --skip-gates --no-interactive
```

The original `umbraco-demo` agent (inline orchestration) and the Conductor variant produce the same site; pick whichever orchestration style you prefer.

## Skills

Reusable skills are found in `/.github/skills` and are auto-discovered by Copilot CLI.

To see available skills, run `/skills list`. Copilot can invoke these automatically, or you can call them explicitly with `/skill-name`.

Demo build order:

1. `/umb-homepage`
1. `/umb-blog-pages`
1. `/umb-navigation`
1. `/umb-sitemap`
1. `/umb-accessibility`
1. `/umb-blogposts`
1. `/umb-tagcloud`
1. `/umb-blogpost-images`

There's also a reset skill to wipe everything back to defaults: `/umb-reset`

There's also a Conductor workflow skill that runs the whole demo end-to-end as a multi-agent workflow: `/umb-demo-conductor` (see "Conductor workflow variant" above).

## Custom agents

All agents are in `/.github/agents` and are auto-discovered by Copilot CLI:

* `umbraco-demo.agent.md` — end-to-end demo orchestrator
* `umbraco-demo-conductor.agent.md` — end-to-end demo orchestrator, run as a Conductor multi-agent workflow (via the `/umb-demo-conductor` skill)
* `umbraco-site-builder.agent.md` — Umbraco implementation specialist
* `umbraco-site-validator.agent.md` — site quality and accessibility specialist

## Instructions

Instructions are found in:

* `/.github/copilot-instructions.md`
* `/.github/instructions/*.instructions.md`

These are the instructions to help keep the AI Agent doing what it is supposed to. These are currently in their infancy and although they work most of the time when running the above skills, sometimes an Agent will get something wrong. In that case, the instructions need to be adjusted.

Pro tip: You can always ask the AI Agent to update the rules in a way that it won't get something wrong again :)

## Next steps

* Maybe this could be changed to a GitHub Template Repository?
* Wonder if we can as a community come up with some great shared rulesets for Umbraco that can be confidently re-used?
* Perhaps there can be some common Umbraco slash commands that can be re-used for majority of Umbraco tasks? Slash commands for many AI tools also support command parameters which could be leveraged for added flexibility.
* Convert this to a SDD (Spec Driven Development) toolset?
* Setup a single npx command to both configure everything and potentially execute commands?
