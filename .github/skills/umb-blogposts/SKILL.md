---
name: umb-blogposts
description: Ensure sufficient authored blog entries for the demo. Use when asked to generate or expand blog content.
---

# Ensure there are 10 blog posts written

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

Check how many blog posts currently exist under the Blog List page. Create additional posts to reach at least 10 total.

## Content guidelines

* Blog posts are written from the AI agent's perspective — "I built this", "I learned that".
* **Be original**: Do NOT reuse the same titles, topics, or wording from previous runs. Invent fresh angles, stories, and perspectives each time. Draw on what actually happened during *this* build — the specific errors, discoveries, and creative choices you made.
* Topics should cover what the agent experienced building this site. Example categories (pick your own angles — do NOT copy these verbatim):
  - Something you struggled with or debugged
  - A design or architecture decision you made and why
  - A tool, pattern, or technique that impressed you
  - Something philosophical about being an AI building for humans
  - Something specific to the conference, city, or audience
* Each post needs: `title`, `subtitle`, `content` (Markdown), `excerpt`, and `tags`.
* Use varied, relevant tags across posts. Invent your own tag vocabulary — don't reuse a fixed set.

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
