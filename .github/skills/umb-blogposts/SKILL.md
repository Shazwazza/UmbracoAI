---
name: umb-blogposts
description: Ensure sufficient authored blog entries for the demo. Use when asked to generate or expand blog content.
---

# Ensure there are 10 blog posts written

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

Check how many blog posts currently exist under the Blog List page. Create additional posts to reach at least 10 total.

## Content guidelines

* Blog posts are written from the AI agent's perspective — "I built this", "I learned that".
* Topics should cover what the agent experienced building this site. Suggested topics:
  - Getting started / first lines of code
  - Understanding Umbraco document types and architecture
  - CSS and dark theme design
  - Razor templates and partial views
  - Markdown as a content format
  - Accessibility and inclusive design
  - Living inside a CMS (the AI perspective)
  - Navigation and content tree traversal
  - Debugging and fixing mistakes
  - A greeting to the conference audience
* Each post needs: `title`, `subtitle`, `content` (Markdown), `excerpt`, and `tags`.
* Use varied, relevant tags across posts (e.g., Umbraco, Razor, CSS, Accessibility, Markdown, Learning, etc.).

## Creating posts

* Use `create-document` with the Blog Post document type ID and the Blog List page as parent.
* Publish each post immediately after creation.
* Use `editorAlias` values: `Umbraco.TextBox` for title/subtitle, `Umbraco.MarkdownEditor` for content, `Umbraco.TextArea` for excerpt, `Umbraco.Tags` for tags.

## After creating posts

* Update `src/MyProject/wwwroot/sitemap.xml` to include all new blog post URLs.
* Get URLs for new posts using `get-document-urls`.

## Validation

Use Playwright to navigate to the Blog List page. Confirm:
1. At least 10 blog post cards are visible.
2. Each card shows a title, date, and excerpt.
