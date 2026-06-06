---
name: umb-image-sourcing
description: Query Unsplash for topical photos and upload them into Umbraco media. Use when sourcing/downloading hero images for blog posts before assigning them.
---

# Source blog hero images from Unsplash

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

This skill is the **image acquisition** half of the blog-images work: it finds
real, topical photos and gets them into the Umbraco media library. The companion
skill `umb-blogpost-images` then **assigns** those media items to posts and
**renders** them in templates.

## Why this is a separate step

Querying Unsplash needs a real API call — the Unsplash website blocks scraping
(HTTP 401) and the old keyless `source.unsplash.com` endpoint is gone (HTTP 503).
So image discovery goes through the dedicated **`unsplash` MCP server**
(`@microlee666/unsplash-mcp-server`), which holds the access key in its own env
and exposes a `search_photos` tool. Generic web fetching of the Unsplash site
will not work.

> The `unsplash` MCP server is for **image discovery only**. NEVER use it — or any
> fetch/HTTP tool — to reach Umbraco. All Umbraco operations go through the
> `umbraco-mcp` tools.

## Prerequisites

* The `unsplash` MCP server must be available (it exposes `search_photos`,
  `get_random_photo`, `track_download`, etc.). If it is **not** in your tool
  list, do not improvise a scrape — go straight to the **Picsum fallback** below
  so the demo never stalls.
* The `umbraco-mcp` media tools must be available for the upload.

## Step 1 — Create the media folder

Create a single **"Blog Hero Images"** media folder (via `create-media-folder`
or `create-media`). Upload every hero image into this folder. Do this once,
before uploading.

## Step 2 — Find one photo per blog post

For each blog post, derive a short, concrete search query from its topic (e.g.
"artificial intelligence", "umbraco cms", "developer workflow", "content
management"). Then:

1. Call `search_photos` with:
   * `query`: the topic keywords
   * `orientation`: `landscape` (hero images are wide)
   * `per_page`: `3` (gives a few candidates)
   * `order_by`: `relevant`
2. From the JSON result, take the first result's image URL. Prefer a crisp,
   sized JPG:
   * Use `results[0].urls.raw` and append `&w=1600&q=80&fm=jpg`, **or**
   * fall back to `results[0].urls.regular` (already ~1080px wide).
3. Record, for the assign step and attribution:
   * the photo `id`
   * the chosen image URL
   * the photographer's `user.name` and `user.links.html` (profile URL)

> **Attribution (Unsplash API requirement):** after selecting a photo you intend
> to use, call `track_download` with that photo `id`. This pings Unsplash's
> required download endpoint. Keep the photographer name/profile so the
> `umb-blogpost-images` step can show a small "Photo by <name> on Unsplash"
> credit.

Keep total searches modest — the demo key is rate-limited (~50 requests/hour),
which is plenty for ~10 posts at one search each.

## Step 3 — Upload the images to Umbraco

Upload all chosen URLs into the **Blog Hero Images** folder using
`create-media-multiple`:

* Use `sourceType: "url"` — `filePath` uploads are disabled by default.
* Pass the direct `images.unsplash.com` URL from Step 2 (Umbraco downloads it
  server-side; these CDN URLs are publicly fetchable).
* Only **PNG/JPG**. No SVG.
* Give each media item a clear name tied to its blog post (e.g.
  `hero-<post-slug>`), so the assign step can match them up.

**Sequential writes only:** issue `create-media`/`create-media-multiple` calls
one at a time — never in parallel (LocalDB uses table-level locks).

## Picsum fallback (so the live demo never breaks)

If the `unsplash` MCP server is unavailable, a search returns nothing, or a URL
fails to upload, fall back to **Lorem Picsum**, which needs no key and always
resolves:

```
https://picsum.photos/seed/<post-slug>/1200/800
```

Use the blog post's slug as the `<seed>` so each post gets a stable, distinct
image. Upload these via `create-media-multiple` with `sourceType: "url"` exactly
as above. Picsum images are not topical, but they guarantee every post has a
working hero. Mention in your summary if the fallback was used.

## Output of this step

A mapping of **blog post -> uploaded media item** (media name/id/key), ready for
`umb-blogpost-images` to assign via `update-document-properties`. If you tracked
attribution, also hand over photographer name + profile URL per post.

## What NOT to do

- DO NOT scrape `unsplash.com` search pages or use `source.unsplash.com` — both
  fail. Use the `unsplash` MCP `search_photos` tool (or the Picsum fallback).
- DO NOT use the `unsplash`/fetch tools to reach Umbraco — only `umbraco-mcp`.
- DO NOT log into the Umbraco backoffice to upload images manually.
- DO NOT use `sourceType: "filePath"` — it is disabled.
- DO NOT upload SVG files — only PNG and JPG.

## Commit

This step is part of the blog-images work and is committed together with
`umb-blogpost-images`. If you run it standalone, commit the media changes:

```
git add -A
git commit -m "Source blog hero images from Unsplash — <brief summary>"
```
