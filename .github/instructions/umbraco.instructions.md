---
description: Umbraco best practices
applyTo: '**/*'
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

## Running the website

* The web application will normally already be running at `SITE_BASE_URL` (see Project Configuration in copilot-instructions.md). If its not, it can be started by running `dotnet run --project src/MyProject/MyProject.csproj` from the root of this workspace.

## Database backup

* Before performing any bulk or destructive operations via the Umbraco MCP tools (e.g., deleting content, resetting the site, creating many items), run the `/umb-backup` skill to back up the LocalDB database.
* Backups are stored at `src/MyProject/umbraco/Data/backups/` and are git-ignored.

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

<pattern name="partial-views">
  <description>All partial views MUST include the `@inherits` directive to access Umbraco helpers like `Model.Root()`.</description>
  <correct>
    ```csharp
    @inherits Umbraco.Cms.Web.Common.Views.UmbracoViewPage
    ```
  </correct>
</pattern>

<pattern name="rich-text-tiptap">
  <description>Rich Text (Tiptap editor) — retrieve with untyped `Model.Value()` and render with `@Html.Raw()`.</description>
  <correct>
    ```csharp
    var content = Model.Value("mainContent");
    @Html.Raw(content)
    ```
  </correct>
  <incorrect reason="returns null for Tiptap rich text">
    ```csharp
    Model.Value&lt;IHtmlContent&gt;("mainContent")
    ```
  </incorrect>
</pattern>

<pattern name="markdown-editor">
  <description>Umbraco converts Markdown to HTML automatically. Retrieve as string and render.</description>
  <correct>
    ```csharp
    var html = Model.Value&lt;string&gt;("content");
    @Html.Raw(html)
    ```
  </correct>
  <incorrect reason="not needed — Umbraco handles Markdown natively">Installing Markdig or other Markdown libraries.</incorrect>
  <incorrect reason="does not resolve in Razor views">Using `HtmlStringUtilities.ReplaceLineBreaks()`.</incorrect>
</pattern>

<pattern name="media-picker-image">
  <description>Media Picker (Image) — retrieve as `IPublishedContent` and call `.Url()`.</description>
  <correct>
    ```csharp
    var heroImage = Model.Value&lt;Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent&gt;("heroImage");
    var imageUrl = heroImage?.Url();
    ```
    Use image processor query strings for cropping: `?width=1200&amp;height=500&amp;mode=crop`.
  </correct>
  <incorrect reason="does not resolve correctly">Using `MediaWithCrops` type.</incorrect>
</pattern>

<pattern name="doctype-template-linking">
  <description>Creating a document type does NOT auto-link a template. After creating both, you must update the document type with `allowedTemplates` and `defaultTemplate` to connect them.</description>
</pattern>

<pattern name="template-creation">
  <description>`create-template` creates both the Umbraco template record AND a minimal `.cshtml` file (just `@inherits` and `Layout = null`). You must edit the `.cshtml` via the filesystem to add your actual HTML/Razor markup.</description>
</pattern>
