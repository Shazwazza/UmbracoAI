---
description: Create a site map and validate
---
# Create a site map and validate pages

## Create site map

* Based on the content in the tree, create and save an xml sitemap. The file can be stored in src\MyProject\wwwroot which will be available on a web request at "/sitemap.xml".
* The absolute URL for a page will be http://localhost:14737 + the relative path/URL of the published document which you can discern from its JSON definition or by calling 'get-document-urls'.
* Ensure Umbraco HTML Templates include a reference to this sitemap.

## Validate page rendering

* Crawl each link in the site map and validate that it doesn't produce any errors by using the 'Playwright' MCP tool to browse to the absolute URL of the published document and ensure there are no errors.
* If there are errors, there will be a 'div' element with an id of 'stackpage'.
* If there is an error, read what the error is that is rendered on the page and fix it in the Template.

## Validate navigation

* Each URL listed in the sitemap should be accessible through navigation on the website.
