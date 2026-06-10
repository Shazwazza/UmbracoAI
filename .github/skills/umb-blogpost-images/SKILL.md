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
* After assigning, republish each blog post.

## Rendering in templates

* In Razor templates, retrieve the hero image with:
  ```csharp
  var heroImage = Model.Value<Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent>("heroImage");
  var heroImageUrl = heroImage?.Url();
  ```
* Use `?width=1200&height=500&mode=crop` for blog post hero images.
* Use `?width=600&height=300&mode=crop` for blog list card thumbnails.
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
