# Project Configuration

There are two local Umbraco sites so the **traditional demo agent** and the
**Conductor workflow** can run at the same time against separate databases.

| Variable | Value | Environment | Launch profile | Database (LocalDB) | Used by |
|----------|-------|-------------|----------------|--------------------|---------|
| `SITE_BASE_URL` | `http://localhost:14737` | `Development` | `Umbraco.Web.UI` | `Umbraco.mdf` | Traditional demo agent / Copilot CLI (`.mcp.json`) |
| `CONDUCTOR_SITE_BASE_URL` | `http://localhost:14738` | `Conductor` | `Conductor` | `UmbracoConductor.mdf` | Conductor workflow (`umbraco-demo.yaml`) |

Start each site from the repo root with its launch profile:

```bash
# Traditional demo site (SITE_BASE_URL)
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Umbraco.Web.UI -p:SiteEnv=Development

# Conductor workflow site (CONDUCTOR_SITE_BASE_URL)
dotnet run --project src/MyProject/MyProject.csproj --launch-profile Conductor -p:SiteEnv=Conductor
```

Run them in two separate terminals to operate both sites concurrently. Each site
uses its own LocalDB database and an isolated temp/Examine folder, so they do not
conflict. The `-p:SiteEnv=...` global property redirects each site's build output
to `bin\<SiteEnv>\` / `obj\<SiteEnv>\` (see `src/MyProject/Directory.Build.props`),
so the two builds never lock each other's `MyProject.exe`. It MUST be passed on the
command line because launch-profile environment variables do not reach the build
phase of `dotnet run`. Each site must be installed once and have the Umbraco API
user created (see README).

> **Note:** `SITE_BASE_URL` is wired through `.mcp.json` (`UMBRACO_BASE_URL`) and
> the `Umbraco.Web.UI` profile in `src/MyProject/Properties/launchSettings.json`.
> `CONDUCTOR_SITE_BASE_URL` is wired through the conductor workflow
> `.github/skills/umb-demo-conductor/umbraco-demo.yaml` (the `site_base_url` input
> default, the `UMBRACO_BASE_URL` env mirror, the `--umbraco-base-url` CLI flag, and
> the literal URL in the shared `instructions:` preamble's "SITE URL" block), the
> `Conductor` profile in `launchSettings.json`, and
> `src/MyProject/appsettings.Conductor.json`. If you
> change either URL/port, update the matching set of files.

# Project Overview

Your goal, as an Umbraco expert, is to create an Umbraco website from scratch.
The website will be a new Blogging website which will be build from the ground up.

When writing content for the website:
* The blog website that you are creating is all about: "You, the AI Agent that built this web application".
* When creating blog posts, they should be about you, what you have learned from building this web app, and really, anything you'd like the folks at the Umbraco Codegarden 2026 conference to know about.
* Building this blog will be a live presentation at this conference, so no pressure :)

## Minimum requirements

* HTML and CSS implementation.
* Umbraco structure and schema defined and created.
* Umbraco content created.
* Umbraco media created.
* Minimum of 5 blog posts.
