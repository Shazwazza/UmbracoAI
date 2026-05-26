---
name: umb-blogpost-images
description: Add hero images to blog posts and render image previews on list and detail pages. Use when asked to add blog media.
---

# Add images to blog posts

* Each blog post should have a hero image.
* Ensure the document type supports a media picker property for this.
* Create a media item for each blog post hero image and upload/assign an image.
  * You can normally use Unsplash for searching for images.
  * For downloading images, use curl commands.
  * Save images to `src/MyProject/wwwroot/media/downloaded_images`.
  * PNG and JPG formats are supported.
  * No SVG files.
* Update the blog post template to render the hero image.
* Update the blog list template to show a thumbnail of the hero image.
* DO NOT try to log into the Umbraco backoffice to manually upload images.
