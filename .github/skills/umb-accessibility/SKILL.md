---
name: umb-accessibility
description: Run accessibility checks and fix issues until passing. Use when asked to test or improve website accessibility.
---

# Website accessibility

## Testing

Use the `a11y-accessibility-test_accessibility` MCP tool to test each page. Pass the full URL (e.g., `http://localhost:14737/`) as the `url` parameter.

Pages to test (based on sitemap or content tree):
1. Home page — `SITE_BASE_URL` (see Project Configuration in copilot-instructions.md)
2. Blog List page — `SITE_BASE_URL/blog/`
3. At least one Blog Post page — e.g., `SITE_BASE_URL/blog/<slug>/`

## Fixing issues

* Review the violations returned by the tool.
* Fix issues in the Razor templates or CSS as needed.
* Common fixes include: adding `<main>` landmarks, ensuring all content is inside landmark regions, correct heading hierarchy.

## Verification

* Re-run `a11y-accessibility-test_accessibility` on each page after fixes.
* Repeat until all pages report zero violations.
