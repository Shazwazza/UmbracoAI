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
   & ".github/skills/umb-sitemap/generate-sitemap.ps1" -BaseUrl "http://localhost:14737" -Urls "/", "/blog/", "/blog/my-post/", ...
   ```
   The script writes `src/MyProject/wwwroot/sitemap.xml` automatically.
3. Ensure Umbraco HTML Templates include a reference to this sitemap.

## Validate page rendering

* Crawl each link in the sitemap and validate it does not produce errors by using Playwright to browse to each URL.
* If there are errors, there will be a `div` element with an id of `stackpage`.
* If there is an error, read what is rendered and fix it in the Template.

## Validate navigation

* Each URL listed in the sitemap should be accessible through navigation on the website.
* Do NOT close the Playwright browser after validation — subsequent steps or the user may need it.
