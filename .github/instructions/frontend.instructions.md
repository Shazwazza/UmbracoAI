---
description: Rules for working with front-end files
applyTo: '**'
---
# Rules for working with front-end files

Page design should be consistent between all pages.

## Umbraco Templates

* When creating Umbraco Templates, this must be done via the Umbraco Template MCP tools.
* After Umbraco Templates have been created, modifying the cshtml file content directly via the file system is acceptable.
* Rendering Umbraco content in the cshtml files DO NOT require additional plugins.
  * Even for markdown editors, etc... Umbraco has all of the functionality built in to render this correctly using the standard syntax: `@Model.Value("propertyName")`.
  * DO NOT install Markdig or other libraries, they are not needed.
* **Do NOT restart the site after editing a `.cshtml`** — Razor views compile at runtime, so a save + browser refresh is enough. Restarting the dotnet site repeatedly wastes minutes per run.

## Partial Views

* Razor partial views or components will need to be manually authored via the file system and stored at: src\MyProject\Views\Partials

## CSS

* CSS will need to be handled by writing to the physical file system.
* CSS files should be stored at: src\MyProject\wwwroot\css.
* CSS files stored there can be referenced in HTML by the absolute path /css/*.
* DO NOT create separate CSS files for every page.
  * There should be one or many CSS files for the whole site.
  * If page specific styles are required, they should be part either stored as part of the main site's CSS files, or included in the page includes as a separate page specific CSS include.
