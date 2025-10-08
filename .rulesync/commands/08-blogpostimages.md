---
description: 'Add images to blog posts'
targets: ["*"]
---

# Add images to blog posts

* Each blog post should have a hero image.
* Ensure the document type supports a media picker property for this.
* Create a media item for each blog post here image and upload/assign an image of your choice.
  * You can normally use unsplash for searching for images.
  * For downloading images, use curl commands.
  * Save images to src/MyProject/wwwroot/media/downloaded_images.
  * PNG, JPG image formats are supported.
  * No svg files.
* Update the blog post template to render the hero image.
* Update the blog list template to show a thumbnail of the hero image.
* DO NOT try to log into the Umbraco backoffice to manually upload images.
