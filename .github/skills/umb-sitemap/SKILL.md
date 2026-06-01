---
name: umb-sitemap
description: Generate sitemap.xml and validate all site links and navigation paths. Use when asked to create or verify sitemap and site rendering.
---

# Create a site map and validate pages

## Create site map

* Based on the content in the tree, create and save an XML sitemap. The file can be stored in `src/MyProject/wwwroot` and should be available at `/sitemap.xml`.
* The absolute URL for a page is `http://localhost:14737` plus the relative URL of the published document.
* Ensure Umbraco HTML Templates include a reference to this sitemap.

## Validate page rendering

* Crawl each link in the sitemap and validate it does not produce errors by using Playwright to browse to each URL.
* If there are errors, there will be a `div` element with an id of `stackpage`.
* If there is an error, read what is rendered and fix it in the Template.

## Validate navigation

* Each URL listed in the sitemap should be accessible through navigation on the website.
