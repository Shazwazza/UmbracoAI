---
description: Rules for using MCP tools
applyTo: '**/*'
---
# Rules for using MCP tools

## Common rules

- **MCP tool unavailable or failing:** If a task/skill asks you to use a specific MCP tool and that tool is either not in your available tool list **or** the tool call fails — **STOP and notify the user**. Do NOT substitute an alternative tool or workaround (e.g. do not swap Playwright + axe-core injection for the a11y MCP tool). The correct response is to report exactly which tool is missing or failing and wait for the user to resolve it.

## Umbraco MCP

- If the Umbraco MCP tool is not running, DO NOT attempt to modify Umbraco content.
- The Umbraco MCP tool may not work if the website is not running. If you determine the website is not running, start it and try again.
- If the website is running and the MCP tool fails, notify the user. DO NOT attempt to complete ANY commands without it operating.
- NEVER use `curl`, `Invoke-RestMethod`, `Invoke-WebRequest`, or any other direct HTTP/API calls to access Umbraco. All Umbraco operations MUST go through the Umbraco MCP tools exclusively. Do NOT attempt to work around MCP failures by calling the Umbraco API directly.
- **Sequential writes only:** Umbraco MCP write operations (create, update, delete, move, publish, unpublish) MUST be called one at a time. Do NOT issue multiple write tool calls in the same parallel batch. Parallel writes cause SQL lock errors on the LocalDB backend. Read-only calls (`get-*`, `search-*`, `find-*`) may be parallelised freely.

## Server process management

- When the Umbraco web server is started with `dotnet run` using `detach: true`, the server process continues running independently even after the shell reports completion. A "detached shell completed" notification does NOT mean the server has stopped.
- Do NOT restart the server when you receive a shell completion notification. Check if the server is actually responsive first (e.g., try navigating with Playwright or check for the dotnet process).

## Browser commands

- Use the "playwright" MCP server for browser commands.
- When navigating to browser URLs, use the `browser_navigate` command.
- When zooming in the browser, use `browser_evaluate` + javascript. Example: `document.body.style.zoom='75%'`
- When scrolling in the browser, use `browser_evaluate` + javascript. Example: `window.scrollTo(0, document.body.scrollHeight)` to scroll to the bottom, `window.scrollTo(0, 0)` to scroll to the top.
- When waiting for a page to load, use the `browser_wait_for` command.
