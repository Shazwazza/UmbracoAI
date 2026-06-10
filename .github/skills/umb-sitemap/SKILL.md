---
name: umb-sitemap
description: Generate sitemap.xml and validate all site links and navigation paths. Use when asked to create or verify sitemap and site rendering.
---

# Create a site map and validate pages

## Create site map

1. Use Umbraco MCP tools to collect all published document URLs:
   - Call `get-document-root` to get root documents, then `get-document-children` recursively.
   - Call `get-document-urls` with all document IDs to get relative URLs.
2. Run the sitemap generator script with the collected URLs:
   ```powershell
   & ".github/skills/umb-sitemap/generate-sitemap.ps1" -BaseUrl "SITE_BASE_URL" -Urls "/", "/blog/", "/blog/my-post/", ...
   ```
   Replace `SITE_BASE_URL` with the configured value (see Project Configuration in copilot-instructions.md). The script writes `src/MyProject/wwwroot/sitemap.xml` automatically.
3. Ensure Umbraco HTML Templates include a reference to this sitemap.

## Validate page rendering

* Every page was already validated in its own build step, so you do NOT need to
  re-crawl all URLs here. Spot-check a **representative sample** with Playwright:
  the home page, the blog list page, two or three blog posts (including one with
  a hero image), and `/sitemap.xml` itself. This keeps validation meaningful
  without crawling the whole site again.
* A page has an error if it renders a `div` element with an id of `stackpage`.
* If there is an error, read what is rendered and fix it in the Template, then
  re-check that page.

## Validate navigation

* Each URL listed in the sitemap should be accessible through navigation on the website.

## Commit

After validation passes, commit all changes before considering this step done:
```
git add -A
git commit -m "Step 7: Sitemap — <brief summary>"
```
This commit is **mandatory**. The step is not complete until the commit exists in the git log.
