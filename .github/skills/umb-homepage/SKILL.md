---
name: umb-homepage
description: Create the Umbraco home page structure, template, styling, and published root content. Use when asked to scaffold or build the home page.
---

# Create a Home page in Umbraco

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

* Ensure the Document Type structure to support a Home page at the root of the content tree.
* Ensure there is a Template assigned for this Document Type.
* Produce the HTML, Razor and CSS to render the Home page and its fields.
* Ensure there is a Home page at the root of the content tree and it is published.

## Validation

Use Playwright to navigate to `SITE_BASE_URL`. Confirm:
1. The page loads without errors (no `div#stackpage` element).
2. The hero section and content render correctly.
