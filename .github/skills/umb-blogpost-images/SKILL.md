---
name: umb-blogpost-images
description: Add hero images to blog posts and render image previews on list and detail pages. Use when asked to add blog media.
---

# Add images to blog posts

> **Git:** Before making changes, verify you are on a `develop/*` branch (see `git.instructions.md`).

* Each blog post should have a hero image.
* Ensure the Blog Post document type has a `heroImage` property using the Image Media Picker data type.

## Getting the images (prerequisite)

Image **acquisition** lives in the separate **`umb-image-sourcing`** skill: it
runs the `.github/skills/umb-image-sourcing/source-blog-images.ps1` discovery script to find Unsplash
photos, uploads each into a "Blog Hero Images" media folder, and hands back a
mapping of blog post -> media item.

* If you have not run `umb-image-sourcing` yet, do it first — it produces the
  media items this skill assigns.
* This skill assumes the hero images already exist in the media library. It only
  **assigns** and **renders** them.

## Assigning images to posts

* Use `update-document-properties` to set the `heroImage` property on each blog post.
* The media picker value format is: `[{"key": "<uuid>", "mediaKey": "<media-id>", "mediaTypeAlias": "Image", "crops": [], "focalPoint": null}]`
  * `key` is a NEW unique GUID for this picker entry (any GUID).
  * `mediaKey` MUST be the real **key (GUID)** of the uploaded media item — read
    it back from the media library; do not guess or reuse the post id.
  * `mediaTypeAlias` MUST match the media item's ACTUAL type. The hero media must
    be **Image** (see `umb-image-sourcing`). Declaring `"Image"` here while the
    media is really a `File` makes publish drop the value.
* After assigning, republish each blog post.
* **Do this in parallel batches to save time:** each post is an independent node, so issue all the `update-document-properties` (heroImage assignment) calls together in one parallel tool batch, wait for them to return, then issue all the `publish-document` calls in one parallel batch. Parallel update + publish of distinct content nodes is verified safe on the LocalDB backend (no deadlocks). Keep the assign→publish order for any given post (assign first, then publish).

### If a hero image won't appear after publishing (READ THIS before retrying)

If the draft has `heroImage` set but `get-document-publish` shows
`"heroImage","value":[]` (empty) on the published version, **do NOT keep
republishing or switch to `update-document` — that wastes time and will not
help.** The value is being stripped at publish because the referenced media is
the wrong type. Fix the cause instead:

1. Read the media item (`get-media-by-id`) and check its media/content type.
2. If it is **File** (not **Image**), the MediaPicker rejects it on publish.
   Re-create that media as an **Image** type (see `umb-image-sourcing`), then
   re-assign using the new media key and republish once.

This is a known Umbraco gotcha, not an MCP bug.

## Rendering in templates

* In Razor templates, retrieve the hero image as `IPublishedContent` and build a
  cropped URL with `GetCropUrl(...)`:
  ```csharp
  var heroImage = Model.Value<Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent>("heroImage");
  var heroImageUrl = heroImage?.GetCropUrl(width: 1200, height: 500);   // hero
  // for list cards: heroImage?.GetCropUrl(width: 600, height: 300)
  ```
* Do NOT hand-build query strings like `?width=1200&height=500&mode=crop`. This
  site has HMAC-signed media URLs enabled, so an unsigned `?width=...` request
  returns **HTTP 400 Bad Request** and the image fails to load. `GetCropUrl`
  produces a correctly signed URL — use it for hero images AND list thumbnails.
* Every `<img>` (hero and thumbnail) MUST have a meaningful `alt` attribute —
  use the blog post title. Accessibility is validated later in the build, so
  do not introduce images without alt text (it would fail a11y).
* Update the blog post template to render the hero image below the header.
* Update the blog list template to show a thumbnail image on each blog card.
* If `umb-image-sourcing` provided photographer attribution, render a small
  "Photo by &lt;name&gt; on Unsplash" credit near the hero image (Unsplash ToS).

## What NOT to do

- DO NOT try to log into the Umbraco backoffice to manually upload images.
- DO NOT use `MediaWithCrops` type in Razor — use `IPublishedContent` instead.
- DO NOT re-source or re-upload images here — that is `umb-image-sourcing`'s job.

## Validation

Use Playwright to:
1. Navigate to the Blog List page. Confirm each blog card shows a thumbnail image.
2. Navigate to at least one Blog Post page. Confirm the hero image renders below the header.

## Commit

After validation passes, commit all changes before considering this step done:
```
git add -A
git commit -m "Step 5: Blog post images — <brief summary>"
```
This commit is **mandatory**. The step is not complete until the commit exists in the git log.
