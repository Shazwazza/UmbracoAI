---
root: false
targets: ["*"]
description: "Umbraco best practices"
globs: ["**/*"]
---

# Umbraco best practices & rules

## When working with Umbraco

- Always use the umbraco-mcp MCP tool for Umbraco backoffice operations
- Follow Umbraco best practices for Document Type and Data Type creation
- Use appropriate property editors and avoid creating custom ones
- Structure content hierarchically and logically
- Implement responsive, accessible frontend code
- Use semantic HTML and modern CSS practices
- Follow the project's content authoring guidelines for friendly, professional content
- Create comprehensive, scalable solutions that can grow with the project needs
- Always consider SEO, performance, and user experience in your implementations
- Be creative with your front-end design, html and css. Come up with a theme and stick to it.

## Running the website

* The web application will normally already be running at http://localhost:14737, if its not, it can be started by running `dotnet run --project src/MyProject/MyProject.csproj` from the root of this workspace.

## Umbraco backoffice and schema

* Do not create or modify Users.
* Do not create or modify Members.
* Do not create or modify Translations or Dictionary items.
* Do not install Packages.
* Do not create or use document blueprints.
* Do not create custom Property Editors, only use the built in ones.
* Do not be concerned about Public Access.
* Do not be concerned about Domains.
* Do not be concerned about Variants or Segments.

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

## Additiona libraries/plugins

DO NOT install additional libraries, plugins or extensions, they are not necessary.