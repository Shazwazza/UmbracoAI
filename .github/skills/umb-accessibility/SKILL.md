---
name: umb-accessibility
description: Run accessibility checks and fix issues until passing. Use when asked to test or improve website accessibility.
---

# Website accessibility

## Testing

Use the `a11y-accessibility-test_accessibility` MCP tool to test each page. Pass the full URL (e.g., `SITE_BASE_URL/`, see Project Configuration in copilot-instructions.md) as the `url` parameter.

Pages to test (based on sitemap or content tree):
1. Home page — `SITE_BASE_URL` (see Project Configuration in copilot-instructions.md)
2. Blog List page — `SITE_BASE_URL/blog/`
3. At least one Blog Post page — e.g., `SITE_BASE_URL/blog/<slug>/`

## Fixing issues

* Review the violations returned by the tool.
* Fix issues in the Razor templates or CSS as needed.
* Common fixes include: adding `<main>` landmarks, ensuring all content is inside landmark regions, correct heading hierarchy.
* **Show the fix live for the audience:** This is a live demo. After applying a fix to a page, immediately navigate to (or reload) that page in Playwright with `browser_navigate` so the audience can see the change happen on screen. Reloading the same URL forces a fresh render and busts any cached CSS. Do this for each page you fix, before moving on.

## Verification

* Re-run `a11y-accessibility-test_accessibility` on each page after fixes.
* After re-testing, navigate/refresh the page in Playwright again so the audience sees the corrected, passing page.
* Repeat until all pages report zero violations.

## Commit

After all pages report zero violations, commit all changes before considering this step done:
```
git add -A
git commit -m "Step 8: Accessibility — <brief summary of fixes>"
```
This commit is **mandatory**. The step is not complete until the commit exists in the git log.
