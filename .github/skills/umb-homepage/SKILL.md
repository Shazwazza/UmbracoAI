---
name: umb-homepage
description: Create the Umbraco home page structure, template, styling, and published root content. Use when asked to scaffold or build the home page.
---

# Create a Home page in Umbraco

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

* Ensure the Document Type structure to support a Home page at the root of the content tree.
* Ensure there is a Template assigned for this Document Type.
* Produce the HTML, Razor and CSS to render the Home page and its fields.
* **Design creativity**: Invent a unique visual theme for this run — pick an original color palette, typography feel, and layout style. Do NOT reuse themes from previous builds.
* Ensure there is a Home page at the root of the content tree and it is published.

## Shared master layout (do this first — it saves time on every later step)

Create a single master Razor layout at `src/MyProject/Views/_Layout.cshtml` that holds the shared page shell — `<!DOCTYPE html>`, `<head>` (meta, `<title>`, the `/css/site.css` link, sitemap link), the navigation/header, the footer, and `@RenderBody()` for the page-specific content. Every page template (`home.cshtml`, `blogList.cshtml`, `blog.cshtml`, etc.) must then set `Layout = "_Layout.cshtml";` and contain **only** its unique content — never its own `<!DOCTYPE>`/`<head>`/`<body>`/nav/footer.

> Do NOT use `Layout = null;` per page and copy the HTML shell into each template. Duplicating the shell forces you to re-edit the same `<head>`, CSS link, nav, and footer in 3+ files on the navigation, tag-cloud, sitemap, and accessibility steps — a large, avoidable time sink. Define the chrome once in `_Layout.cshtml`.

The `_Layout.cshtml` is a plain Razor layout authored directly on the filesystem (not an Umbraco template created via MCP). It should still start with `@inherits Umbraco.Cms.Web.Common.Views.UmbracoViewPage` so Umbraco helpers (e.g. `Model.Root()`) work inside it.

## Rendering images (READ THIS before adding any `<img>`)

This site has **HMAC-signed media URLs** enabled. The moment you render *any*
image that needs resizing/cropping (a home hero, a logo, anything), you MUST use
`GetCropUrl` — **never** hand-build a query string. An unsigned
`?width=...&height=...&mode=crop` URL returns **HTTP 400 Bad Request** and the
image silently fails to load, which has repeatedly cost time on past runs.

```csharp
var heroImage = Model.Value<Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent>("heroImage");
var heroImageUrl = heroImage?.GetCropUrl(width: 1600, height: 600);
```

`GetCropUrl` generates the correctly signed URL automatically. This applies to
every template in the site, so adopt it from the very first image you render.

## Validation

Use Playwright to navigate to `SITE_BASE_URL`. Confirm:
1. The page loads without errors (no `div#stackpage` element).
2. The hero section and content render correctly.

## Commit

After validation passes, commit all changes before considering this step done:
```
git add -A
git commit -m "Step 1: Home page — <brief summary of what was created>"
```
This commit is **mandatory**. The step is not complete until the commit exists in the git log.
