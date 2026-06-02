---
description: Rules for using MCP tools
applyTo: '**/*'
---
# Rules for using MCP tools

## Common rules

- **MCP tool failure:** If a task/command asks to use a specific MCP tool and the tool fails, DO NOT try to use an alternative.

## Umbraco MCP

- If the Umbraco MCP tool is not running, DO NOT attempt to modify Umbraco content.
- The Umbraco MCP tool may not work if the website is not running. If you determine the website is not running, start it and try again.
- If the website is running and the MCP tool fails, notify the user. DO NOT attempt to complete ANY commands without it operating.
- NEVER use `curl`, `Invoke-RestMethod`, `Invoke-WebRequest`, or any other direct HTTP/API calls to access Umbraco. All Umbraco operations MUST go through the Umbraco MCP tools exclusively. Do NOT attempt to work around MCP failures by calling the Umbraco API directly.

## Server process management

- When the Umbraco web server is started with `dotnet run` using `detach: true`, the server process continues running independently even after the shell reports completion. A "detached shell completed" notification does NOT mean the server has stopped.
- Do NOT restart the server when you receive a shell completion notification. Check if the server is actually responsive first (e.g., try navigating with Playwright or check for the dotnet process).

## Browser commands

- Use the "playwright" MCP server for browser commands.
- When navigating to browser URLs, use the `browser_navigate` command.
- When zooming in the browser, use `browser_evaluate` + javascript. Example: `document.body.style.zoom='75%'`
- When scrolling in the browser, use `browser_evaluate` + javascript. Example: `window.scrollTo(0, document.body.scrollHeight)` to scroll to the bottom, `window.scrollTo(0, 0)` to scroll to the top.
- When waiting for a page to load, use the `browser_wait_for` command.
