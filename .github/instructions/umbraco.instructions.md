---
description: Umbraco best practices
applyTo: '**'
---
# Umbraco best practices & rules

## When working with Umbraco

- Always use the umbraco-mcp MCP tool for Umbraco backoffice operations
- Follow Umbraco best practices for Document Type and Data Type creation
- Use appropriate property editors and avoid creating custom ones
- Structure content hierarchically and logically
- Implement responsive, accessible frontend code
- Use semantic HTML and modern CSS practices
- Always consider SEO, performance, and user experience in your implementations
- Be creative with your front-end design, html and css. Come up with a theme and stick to it
- **Design variety**: Each time you build the site, invent a brand-new visual identity — choose a unique color palette, typography feel, and layout style. Do NOT reuse themes from previous runs. Surprise the audience.
- DO NOT try to log into the Umbraco backoffice manually with the browser
- **Always publish after create/update:** After creating or updating any Umbraco document (content node) via MCP, immediately call `publish-document`. Drafts are invisible on the front-end. This is non-negotiable — unpublished content will silently break the site.
- **Sequential MCP write operations:** All Umbraco MCP write operations (create, update, delete, move, publish, unpublish) MUST be executed one at a time — never in parallel. The LocalDB backend uses table-level locks; parallel writes cause SQL deadlock errors. Read operations (`get-*`, `search-*`, `find-*`) may still be parallelised.

## Running the website

* The web application will normally already be running at `SITE_BASE_URL` (see Project Configuration in copilot-instructions.md). If its not, it can be started by running `dotnet run --project src/MyProject/MyProject.csproj --launch-profile Umbraco.Web.UI -p:SiteEnv=Development` from the root of this workspace. The `-p:SiteEnv=Development` global property redirects the build output to `bin\Development\` so it never locks the Conductor site's `MyProject.exe` when both run at once.

## Umbraco backoffice and schema

<prohibited-actions>
  <action>Do not create or modify Users.</action>
  <action>Do not create or modify Members.</action>
  <action>Do not create or modify Translations or Dictionary items.</action>
  <action>Do not install Packages.</action>
  <action>Do not create or use document blueprints.</action>
  <action>Do not create custom Property Editors — only use the built-in ones.</action>
  <action>Do not be concerned about Public Access.</action>
  <action>Do not be concerned about Domains.</action>
  <action>Do not be concerned about Variants or Segments.</action>
  <action>DO NOT install additional libraries, plugins or extensions — they are not necessary.</action>
</prohibited-actions>

### Umbraco page requirements

Defines the minimal Document Types that will need to be created with Templates:

* Home page
* Blog List page
* Blog page
  * Should support Markdown or Rich Text for content.
  * Should have all of the typical attributes that a Blog page has such as
    * Create/Update date
    * SLUG
    * Title
    * Sub title
    * Image header
    * Tags
    * etc...

## Razor & rendering patterns

These are known-good patterns for rendering Umbraco content in Razor views. Follow them to avoid common compilation errors.

### Partial views

All partial views MUST include the `@inherits` directive to access Umbraco helpers like `Model.Root()`:
```csharp
@inherits Umbraco.Cms.Web.Common.Views.UmbracoViewPage
```

### Rich Text (Tiptap editor)

Retrieve with untyped `Model.Value()` and render with `@Html.Raw()`:
```csharp
var content = Model.Value("mainContent");
@Html.Raw(content)
```
Do NOT use `Model.Value<IHtmlContent>()` — it returns null for Tiptap rich text.

### Markdown editor

Umbraco converts Markdown to HTML automatically. Just retrieve as string and render:
```csharp
var html = Model.Value<string>("content");
@Html.Raw(html)
```
Do NOT install Markdig or other Markdown libraries. Do NOT use `HtmlStringUtilities.ReplaceLineBreaks()` — it does not resolve in Razor views.

### Media Picker (Image)

Retrieve as `IPublishedContent` and call `.Url()`:
```csharp
var heroImage = Model.Value<Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent>("heroImage");
var imageUrl = heroImage?.Url();
```
Do NOT use `MediaWithCrops` — it does not resolve correctly. Use image processor query strings for cropping: `?width=1200&height=500&mode=crop`.

### Document type + template linking

Creating a document type does NOT auto-link a template. After creating both, you must update the document type with `allowedTemplates` and `defaultTemplate` to connect them.

### Template creation

`create-template` creates both the Umbraco template record AND a minimal `.cshtml` file (just `@inherits` and `Layout = null`). You must edit the `.cshtml` via the filesystem to add your actual HTML/Razor markup.
