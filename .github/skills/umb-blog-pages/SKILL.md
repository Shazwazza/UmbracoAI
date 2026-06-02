---
name: umb-blog-pages
description: Create Blog List and Blog page document types, templates, and starter content. Use when asked to set up blog pages in Umbraco.
---

# Create Blog pages in Umbraco

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

* Ensure the Document Type structure to support a Blog List page that can exist under the Home page.
  * Ensure there is a Template assigned for this Document Type.
  * Produce the HTML, Razor and CSS to render the Blog List page with links to the latest Blog posts.
  * Ensure there is a Blog List created under the Home page and published.
  * Ensure this document type has a Collection type of List View Content.
* Ensure the Document Type structure to support a Blog page that can exist under the Blog List page.
  * Blog posts should be authored in Markdown so choose an appropriate property editor to allow for this.
  * Ensure there is a Template assigned for this Document Type.
  * Produce the HTML, Razor and CSS to render the Blog page.
  * Ensure there are a few Blog pages created and published.

## Validation

Use Playwright to:
1. Navigate to the Blog List page URL. Confirm it loads without errors (no `div#stackpage`).
2. Confirm at least one blog post card is visible with title, date, and excerpt.
3. Click through to a blog post. Confirm it renders without errors.

## Commit

After validation passes, commit all changes before considering this step done:
```
git add -A
git commit -m "Step 2: Blog pages — <brief summary of what was created>"
```
This commit is **mandatory**. The step is not complete until the commit exists in the git log.
