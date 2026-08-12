# Umbraco and Copilot CLI

Prompting, rules, skills and agents for building and evolving Umbraco sites with AI agents — packaged so they live in a git repository and can be re-used.

The premise: point an autonomous agent at an empty Umbraco install and have it design, scaffold, style, populate, validate and commit a complete blogging website — without anyone opening the back office or writing a line of code.

## Umbraco Codegarden 2026

This repo is the live-demo material for **"Automate All the Things: Building & Evolving Umbraco Sites with AI Agents"** by Shannon Deminick (Thompson).

* ▶️ **[Watch the recording](https://www.youtube.com/watch?v=A_EUvX8naHQ)** (Umbraco HQ)
* 📊 **Slides:** [`Umbraco Codegarden 2026 Slides Template.pptx`](./Umbraco%20Codegarden%202026%20Slides%20Template.pptx)

The talk and slides cover the *why* — Conductor, agent loops, model comparisons, cost, and where this is all heading. **This README covers the *how*: getting the demo running yourself.**

## Quick Start

1. Clone/fork this repo and open it in your Copilot-enabled editor.
1. Install Playwright browsers as admin: `npx playwright install`
1. Start the Umbraco site (see [Running the site](#running-the-site)) and let it install.
1. [Create an Umbraco API User](https://docs.umbraco.com/umbraco-cms/fundamentals/data/users/api-users) whose credentials match `/.mcp.json`.
1. Start the Playwright MCP server: `powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1`
1. Check `/.mcp.json` points at the site you want to drive — see [Ports and MCP configuration](#ports-and-mcp-configuration).
1. Start Copilot CLI and run one of:
   * `Use the umbraco-demo agent` — end-to-end, single agent
   * `Use the umbraco-demo-conductor agent` — end-to-end, Conductor workflow
   * an individual skill, e.g. `/umb-homepage`

## What's already in `main`

`main` is not an empty starting point — it contains a **completed example site** from a real demo run:

| Area | What's there |
|------|--------------|
| Document types | `home`, `bloglist`, `blogpost` (`src/MyProject/uSync/v17/ContentTypes`) |
| Templates | `home.cshtml`, `blogList.cshtml`, `blogPost.cshtml` (`src/MyProject/Views`) |
| Layout & partials | `_Layout.cshtml`, `Partials/Navigation.cshtml` |
| Styling | One site-wide stylesheet, `src/MyProject/wwwroot/css/site.css` |
| Content | Home, Blog List, and 10 authored blog posts (`uSync/v17/Content`) |
| Media | A "Blog Hero Images" folder with 10 hero images (`uSync/v17/Media`) |
| SEO | A generated `wwwroot/sitemap.xml` |

Each demo step is its own commit (`Step 1a`, `Step 1b`, `Step 2`, …), so you can walk the build one step at a time. The theme is regenerated every run — the agent is instructed to invent a new visual identity each time.

To build your own, run `/umb-reset` (optionally `/umb-backup` first), then the demo agent or Conductor workflow.

> ℹ️ **If you restore the uSync snapshot into a fresh database,** make sure the export is complete. Two things are easy to lose: the Markdown *Data Type* (Umbraco ships the `Umbraco.MarkdownEditor` property editor but no Markdown data type, so the agent creates one during the build), and the `_layout` template that the page templates inherit from. Missing either shows up as `Cannot find underling DataType …` with empty post bodies, or pages that fail to route. Both are committed under `uSync/v17/`. Everything else the site references is an Umbraco built-in.

## Repo layout

| Path | Purpose |
|------|---------|
| `/.github/copilot-instructions.md` | Project config, site URLs, goal, minimum requirements |
| `/.github/instructions/*.instructions.md` | Content, front-end, git, tools and Umbraco rules |
| `/.github/skills/*/SKILL.md` | Reusable skills |
| `/.github/agents/*.agent.md` | Custom agents |
| `/.github/plugin/` | Copilot CLI plugin + marketplace manifests |
| `/.mcp.json` | MCP servers |
| `/scripts/start-playwright-mcp.ps1` | Starts the shared headed Playwright MCP server |

### Install as a Copilot CLI plugin

```bash
copilot plugin install Shazwazza/UmbracoAI
```

Or register this repo as a marketplace first:

```bash
copilot plugin marketplace add Shazwazza/UmbracoAI
copilot plugin install umbracoai-demo@umbracoai-marketplace
```

## Running the site

```bash
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Umbraco.Web.UI -p:SiteEnv=Development
```

`-p:SiteEnv=Development` redirects build output to `bin\Development\` / `obj\Development\` (see `src/MyProject/Directory.Build.props`) so this site never locks the Conductor site's `MyProject.exe` when both run at once. It **must** be on the command line — launch-profile environment variables don't reach the build phase of `dotnet run`.

The site installs unattended on first boot. You then need an [Umbraco API user](https://docs.umbraco.com/umbraco-cms/fundamentals/data/users/api-users) matching the credentials in `/.mcp.json`.

### Umbraco MCP

Configure the [Umbraco MCP server](https://github.com/umbraco/Umbraco-CMS-MCP-Dev), then edit `/.mcp.json` to match your settings. All its commands are *always allow*, but the server is filtered to these tool collections:

```
data-type, document-type, document, media, property-type,
partial-view, static-file, stylesheet, temporary-file, imaging, template
```

The agents never touch Umbraco over raw HTTP — every back-office operation goes through MCP.

### Ports and MCP configuration

There are two Umbraco sites so the demo agent and the Conductor workflow can run simultaneously against separate databases:

| Site | Env / launch profile | URL | LocalDB database | Playwright MCP |
|------|----------------------|-----|------------------|----------------|
| Traditional demo | `Development` / `Umbraco.Web.UI` | `http://localhost:14737` | `Umbraco.mdf` | `http://localhost:8931/mcp` |
| Conductor workflow | `Conductor` / `Conductor` | `http://localhost:14738` | `UmbracoConductor.mdf` | `http://localhost:8932/mcp` |

> ⚠️ **Check `/.mcp.json` before you run.** It can only point at one site at a time, and it is currently checked in pointing at the **Conductor** site (`UMBRACO_BASE_URL=http://localhost:14738`, Playwright `8932`). To drive the traditional site with the `umbraco-demo` agent, switch those to `14737` and `8931`.
>
> The Conductor workflow ignores `/.mcp.json` — it declares its own MCP servers in `umbraco-demo.yaml` and passes `--umbraco-base-url http://localhost:14738` as a CLI flag, precisely because `.mcp.json` would otherwise leak its `UMBRACO_BASE_URL` into the workflow.

If you change a URL/port, update the matching set of files:

* `14737` → `/.mcp.json`, the `Umbraco.Web.UI` profile in `src/MyProject/Properties/launchSettings.json`, `/.github/copilot-instructions.md`, `/.github/agents/umbraco-demo.agent.md`
* `14738` → `/.github/skills/umb-demo-conductor/umbraco-demo.yaml` (input default, `UMBRACO_BASE_URL`, the `--umbraco-base-url` flag, and the shared `instructions:` preamble), the `Conductor` profile in `launchSettings.json`, `src/MyProject/appsettings.Conductor.json`

### Running two sites at once

Start each in its own terminal from the repo root:

```bash
# Terminal 1 — traditional demo site
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Umbraco.Web.UI -p:SiteEnv=Development

# Terminal 2 — Conductor workflow site
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Conductor -p:SiteEnv=Conductor
```

Each profile sets `ASPNETCORE_ENVIRONMENT`, so the second site loads `appsettings.Conductor.json` (separate LocalDB database, unique `SiteName`, and `LocalTempStorageLocation: EnvironmentTemp` so Examine indexes and content cache don't clash). Each database must be installed once and have its own API user.

Each flow also needs its own Playwright MCP server so the two demos appear in **separate** visible browser windows (the browser profile is per-port, so they don't clash):

```powershell
# Window 1 — traditional demo agent (port 8931, the default)
powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1
# Window 2 — Conductor workflow (port 8932)
powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1 -Port 8932
```

Both are launched headed, detached and with `--shared-browser-context`, so the browser survives the run — the agents are explicitly instructed never to close it mid-demo.

## Skills

Skills live in `/.github/skills` and are auto-discovered by Copilot CLI. Run `/skills list` to see them, or call one explicitly with `/skill-name`.

**Optional pre-step:** `/umb-backup` (backs up the LocalDB database) and `/umb-reset` (wipes generated templates, content, media, document types and CSS).

**Build order** — the exact sequence run by both the `umbraco-demo` agent and the Conductor workflow:

| # | Skill | What it does |
|---|-------|--------------|
| 1 | `/umb-homepage` | Home page document type, template, styling and published root content |
| 2 | `/umb-blog-pages` | Blog List + Blog Post document types and templates, plus one starter post |
| 3 | `/umb-navigation` | Shared navigation partial with active state |
| 4 | `/umb-blogposts` | Tops the site up to 10 authored blog posts |
| 5 | `/umb-image-sourcing` | Sources topical photos from Unsplash and uploads them to Umbraco media |
| 6 | `/umb-blogpost-images` | Assigns hero images and renders them on list and detail pages |
| 7 | `/umb-tagcloud` | Frequency-sized, keyboard-accessible tag cloud on the Blog List page |
| 8 | `/umb-sitemap` | Generates `sitemap.xml` and crawls every URL to verify it renders |
| 9 | `/umb-accessibility` | Runs a11y checks via MCP and fixes issues until they pass |

Every step is validated in Playwright and committed before the next one starts.

Notes:

* Accessibility runs **last** deliberately — by then all content, images and the tag cloud exist, so the check covers the finished site.
* The tag cloud renders sized, accessible links but doesn't filter — there's no core Umbraco API for tag-based content queries.

`/umb-demo-conductor` runs the whole thing end-to-end as a Conductor workflow (below).

## Agents

In `/.github/agents`, auto-discovered by Copilot CLI:

* `umbraco-demo.agent.md` — end-to-end demo orchestrator
* `umbraco-demo-conductor.agent.md` — the same demo as a Conductor multi-agent workflow
* `umbraco-site-builder.agent.md` — Umbraco implementation specialist
* `umbraco-site-validator.agent.md` — site quality and accessibility specialist

## Conductor workflow variant

The workflow at `/.github/skills/umb-demo-conductor/umbraco-demo.yaml` runs the same build as a [Conductor](https://github.com/microsoft/conductor) multi-agent workflow — this is what was demonstrated live. Each step includes its existing `SKILL.md`, so both orchestration styles share the same instructions and produce the same site. It adds a human-in-the-loop gate before the reset, parallel fan-out for authoring blog posts, and a git commit per step.

It targets its **own** Umbraco site (`Conductor` profile, `http://localhost:14738`) so it can run alongside the traditional agent:

```bash
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Conductor -p:SiteEnv=Conductor
```

Start the Conductor's Playwright server **first** (port 8932), or later steps run in a hidden browser:

```powershell
# 1. Start the headed Playwright MCP server on port 8932 (detached, idempotent)
powershell -ExecutionPolicy Bypass -File scripts/start-playwright-mcp.ps1 -Port 8932
# 2. Start your Copilot CLI session
# 3. Run the workflow
```

Then either `Use the umbraco-demo-conductor agent`, or run it directly. Always pass `--web` for the live dashboard; add `--skip-gates --no-interactive` for a hands-off run (auto-accepts the gate's first option — back up + reset — and avoids blocking on stdin):

```bash
conductor run .github/skills/umb-demo-conductor/umbraco-demo.yaml --workspace-instructions --web --skip-gates --no-interactive
```

`--workspace-instructions` passes this repo's `copilot-instructions.md` and `instructions/` files into every step's context. It's optional.

## Autopilot / "YOLO mode"

The demo runs unattended. In Copilot CLI, `Shift+Tab` switches to **plan mode**; approving a plan lets you continue in **autopilot** (auto-approve everything) and optionally **fleet** mode (parallel work). To support that, MCP servers in `/.mcp.json` are registered with `"tools": ["*"]`, and command-line tools like `dotnet`, `git`, `npx` and `powershell` are auto-approved.

## uSync

uSync is installed so schema and content changes are written to disk as the agent works. You can watch back-office changes appear as files live during a demo, and everything is tracked in git alongside the code — so any change can be rolled forward or back.

The committed snapshot lives in `src/MyProject/uSync/v17/` (`DataTypes`, `ContentTypes`, `Templates`, `Content`, `Media`). Only Data Types the agent creates need to be exported; the built-in ones ship with Umbraco and are resolved by their well-known keys.
## Next steps

* Maybe this becomes a GitHub Template Repository?
* Could the community converge on shared, re-usable Umbraco rulesets?
* Common Umbraco slash commands, with parameters, for the majority of Umbraco tasks?
* Convert this to an SDD (Spec Driven Development) toolset?
* A single `npx` command that configures everything and can execute the commands?
