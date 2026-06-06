---
name: umb-image-sourcing
description: Source topical photos from Unsplash via a discovery script and upload them into Umbraco media. Use when sourcing/downloading hero images for blog posts before assigning them.
---

# Source blog hero images from Unsplash

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

This skill is the **image acquisition** half of the blog-images work: it finds
real, topical photos and gets them into the Umbraco media library. The companion
skill `umb-blogpost-images` then **assigns** those media items to posts and
**renders** them in templates.

## Why this is a separate step

Querying Unsplash needs a real API call with a key — the Unsplash website blocks
scraping (HTTP 401) and the old keyless `source.unsplash.com` endpoint is gone
(HTTP 503). To keep this out of the model's context, image discovery is done by a
small script, **`scripts/source-blog-images.ps1`**, which queries the Unsplash API
and prints a compact JSON mapping. You run it **once** for all posts instead of
making one Unsplash tool call per post (which would flood the context).

> The script does **image discovery only** — it never touches Umbraco. Uploading
> the returned URLs into the media library is done below via the `umbraco-mcp`
> tools. NEVER use any fetch/HTTP tool to reach Umbraco.

## Prerequisites

* A PowerShell host (`pwsh` or `powershell`) to run the discovery script. The
  script holds a default Unsplash key and also reads `UNSPLASH_ACCESS_KEY` from
  the environment; if Unsplash fails it falls back to Lorem Picsum automatically,
  so the demo never stalls.
* The `umbraco-mcp` media tools must be available for the upload.

## Step 1 — Create the media folder

Create a single **"Blog Hero Images"** media folder (via `create-media-folder`
or `create-media`). Upload every hero image into this folder. Do this once,
before uploading.

## Step 2 — Discover one photo per blog post (run the script once)

Build a small list of `{slug, query}` objects — one per blog post — deriving a
short, concrete search query from each post's topic (e.g. "artificial
intelligence", "umbraco cms", "developer workflow", "content management"). Then
run the discovery script **once** with that list:

```
pwsh scripts/source-blog-images.ps1 -Posts '[{"slug":"my-post","query":"artificial intelligence"}, ...]'
```

(For a long list, write the JSON to a temp file and pass `-InputFile <path>`
instead of `-Posts`.)

The script prints a single compact JSON array — one object per post — that you
read back directly:

```json
[{ "slug": "...", "query": "...", "url": "https://images.unsplash.com/...",
   "source": "unsplash", "photographer": "...", "profile": "https://unsplash.com/@...",
   "photoId": "..." }]
```

For each post it picks the most relevant landscape photo, builds a sized JPG CDN
URL, records the photographer name + profile for attribution, and pings
Unsplash's required download endpoint — all internally. If Unsplash is
unavailable, returns nothing, or is rate-limited, that post's `url` falls back to
a stable Lorem Picsum image and `source` is `"picsum"`.

> **Attribution:** keep each post's `photographer` and `profile` so the
> `umb-blogpost-images` step can show a small "Photo by &lt;name&gt; on Unsplash"
> credit near the hero. Picsum entries have no photographer and need no credit.

## Step 3 — Upload the images to Umbraco

Upload every `url` from the script output into the **Blog Hero Images** folder
using `create-media-multiple`:

* Use `sourceType: "url"` — `filePath` uploads are disabled by default.
* Pass the URL exactly as returned (Umbraco downloads it server-side; both the
  `images.unsplash.com` and `picsum.photos` URLs are publicly fetchable).
* Only **PNG/JPG**. No SVG.
* Give each media item a clear name tied to its blog post (e.g.
  `hero-<post-slug>`), so the assign step can match them up.

**Sequential writes only:** issue `create-media`/`create-media-multiple` calls
one at a time — never in parallel (LocalDB uses table-level locks).

## Fallback note

The script already falls back to Lorem Picsum
(`https://picsum.photos/seed/<slug>/1200/800`) per post whenever Unsplash cannot
serve an image, so every post always has a working hero. Mention in your summary
if any posts used the Picsum fallback (`source: "picsum"`).

## Output of this step

A mapping of **blog post -> uploaded media item** (media name/id/key), ready for
`umb-blogpost-images` to assign via `update-document-properties`. If you tracked
attribution, also hand over photographer name + profile URL per post.

## What NOT to do

- DO NOT scrape `unsplash.com` search pages or use `source.unsplash.com` — both
  fail. Use `scripts/source-blog-images.ps1` for discovery (it falls back to
  Picsum automatically).
- DO NOT use any fetch/HTTP tool to reach Umbraco — only `umbraco-mcp`.
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
