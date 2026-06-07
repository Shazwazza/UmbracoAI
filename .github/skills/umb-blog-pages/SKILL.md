---
name: umb-blog-pages
description: Create Blog List and Blog page document types and templates, plus exactly one starter blog post. Use when asked to set up blog pages in Umbraco.
---

# Create Blog pages in Umbraco

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

> **Scope — read first:** This step builds the blog *structure* (document types
> and templates) and **exactly ONE** starter blog post to prove it renders. Do
> **NOT** create more than one blog post in this step.

* Ensure the Document Type structure to support a Blog List page that can exist under the Home page.
  * Ensure there is a Template assigned for this Document Type.
  * Produce the HTML, Razor and CSS to render the Blog List page with links to its child Blog posts.
  * Ensure there is a Blog List created under the Home page and published.
  * Ensure this document type has a Collection type of List View Content.
* Ensure the Document Type structure to support a Blog page that can exist under the Blog List page.
  * Blog posts should be authored in Markdown so choose an appropriate property editor to allow for this.
  * Ensure there is a Template assigned for this Document Type.
  * Produce the HTML, Razor and CSS to render the Blog page.
  * Create and publish **exactly one** Blog page (a single starter post). Do **not** create a second post.

## Validation

Use Playwright to:
1. Navigate to the Blog List page URL. Confirm it loads without errors (no `div#stackpage`).
2. Confirm the single blog post card is visible with title, date, and excerpt.
3. Click through to the blog post. Confirm it renders without errors.

## Commit

After validation passes, commit all changes before considering this step done:
```
git add -A
git commit -m "Step 2: Blog pages — <brief summary of what was created>"
```
This commit is **mandatory**. The step is not complete until the commit exists in the git log.
