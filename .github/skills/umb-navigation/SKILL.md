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

## Testing

* Once the navigation has been created or updated, test that it renders correctly using the Playwright MCP tool.
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
