---
name: umb-navigation
description: Implement shared site navigation and validate rendering with Playwright. Use when asked to add or improve navigation.
---

# Create page navigation

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

* There must be a menu applied to all pages.
* The Home page must link to relevant pages in the site.
* Other pages must have a way to get back home.
* Navigation and menus may work contextually depending on the current page.

## Razor

* Since page navigation is a shared component, a razor partial view can be used which is stored under `src/MyProject/Views/Partials`.
* Render the navigation partial **once** from the master `_Layout.cshtml` (created in the home-page step), not separately inside each page template. Because every page already inherits `_Layout.cshtml`, adding the nav to the layout makes it appear on all pages automatically — do not paste the nav markup or `Html.PartialAsync("Navigation")` call into individual templates.

### Known-good Navigation partial (copy this — do NOT trial-and-error)

Use this exact shape for `src/MyProject/Views/Partials/Navigation.cshtml`. It compiles first time. Re-style the markup/classes/labels to match your theme, but keep the data-access pattern identical. **Do NOT replace it with your own "more dynamic" navigation** — past runs that rewrote the data-access logic from scratch threw a Razor compilation exception (HTTP 500) and burned several minutes recovering. Start from this partial and change only the presentation:

```razor
@inherits Umbraco.Cms.Web.Common.Views.UmbracoViewPage
@{
    var home = Model.Root();
    var blogList = home.Children().FirstOrDefault(x => x.ContentType.Alias == "blogList");
}
<nav>
    <a href="@home.Url()" class="@(Model.Id == home.Id ? "active" : "")">Home</a>
    @if (blogList != null)
    {
        <a href="@blogList.Url()" class="@(Model.Id == blogList.Id || Model.Parent?.Id == blogList.Id ? "active" : "")">Blog</a>
    }
</nav>
```

**Avoid these compile traps that have cost ~5 minutes of failed iteration on past runs (they throw a Razor _compilation exception_ → site returns HTTP 500 / shows `div#stackpage`):**
* The partial MUST start with `@inherits Umbraco.Cms.Web.Common.Views.UmbracoViewPage`. Without it `Model.Root()`/`Model.Id` won't resolve.
* Use `home.Children()` (the **method**, an `Umbraco.Extensions` extension) — NOT `home.Children` as a property.
* `System.Linq` (`FirstOrDefault`, `Where`) and `Umbraco.Extensions` are already globally available via `_ViewImports.cshtml` + implicit usings — do NOT add extra `@using` directives hunting for them; that is not the cause of compile errors.
* Null-guard the root/children (`Model.Root()` can be null very early; `blogList` may not exist yet) with `?.` and an `@if` as shown — unguarded access is the usual real cause of the 500.
* Active-state is determined by comparing `Model.Id`/`Model.Parent?.Id` to the nav node id (URL/string parsing is unnecessary and fragile).

## Testing

* Once the navigation has been created or updated, test that it renders correctly using the Playwright MCP tool.
* **Do NOT restart the site after editing a `.cshtml`** — Razor views compile at runtime, so a save + browser refresh is enough. A 500 / `div#stackpage` immediately after a `.cshtml` edit is a Razor **compilation error in the view you just changed**, NOT a stale-process problem — restarting will NOT fix it and just wastes minutes. Never `Stop-Process` the dotnet site or run `dotnet run` to recover from a 500 here.
* **Diagnose a 500 by reading the Umbraco trace log, NOT by guessing, restarting, or curling the site.** Open the newest `src/MyProject/umbraco/Logs/UmbracoTraceLog.*.json` and find the compilation error line + line number. Do NOT use `Invoke-WebRequest`/`curl` to probe the site or read the detached `dotnet run` console log — the compilation exception with its line number is in the Umbraco trace log. Fix the partial, then just refresh the browser.
* Navigate to `SITE_BASE_URL` and verify:
  1. Navigation links are visible on all pages (Home, Blog List, Blog Post).
  2. Clicking each nav link loads the correct page without errors.
  3. Each page has a way to return to the Home page.

## Commit

After validation passes, commit all changes before considering this step done:
```
git add -A
git commit -m "Step 3: Navigation — <brief summary of what was added>"
```
This commit is **mandatory**. The step is not complete until the commit exists in the git log.
