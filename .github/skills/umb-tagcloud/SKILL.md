---
name: umb-tagcloud
description: Build a tag cloud on the blog list page based on blog post tag frequency. Use when asked for tag cloud functionality.
---

# Create a Tag Cloud for the Blog List page

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

For the Blog List page template, render a tag cloud that shows all tags used by blog posts, where each tag's visual size is determined by how many times the tag occurs.

## Accessibility

Accessibility is validated earlier in the build, so keep the tag cloud markup accessible — do not regress it:

* Render each tag as a real, keyboard-focusable link (`<a>`) with discernible text content (the tag name).
* Do not convey meaning through size or colour alone; the tag text must always be readable.
* Ensure tag text keeps sufficient colour contrast against the background at every size.

## Validation

Use Playwright to navigate to the Blog List page. Confirm:
1. A tag cloud section is visible with multiple tags.
2. Tags that appear more frequently are visually larger than less common tags.

## Commit

After validation passes, commit all changes before considering this step done:
```
git add -A
git commit -m "Step 6: Tag cloud — <brief summary>"
```
This commit is **mandatory**. The step is not complete until the commit exists in the git log.
