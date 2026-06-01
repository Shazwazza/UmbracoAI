---
name: umb-tagcloud
description: Build a tag cloud on the blog list page based on blog post tag frequency. Use when asked for tag cloud functionality.
---

# Create a Tag Cloud for the Blog List page

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

For the Blog List page template, render a tag cloud that shows all tags used by blog posts, where each tag's visual size is determined by how many times the tag occurs.

## Validation

Use Playwright to navigate to the Blog List page. Confirm:
1. A tag cloud section is visible with multiple tags.
2. Tags that appear more frequently are visually larger than less common tags.
