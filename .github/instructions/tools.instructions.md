---
description: Rules for using MCP tools
applyTo: '**/*'
---
# Rules for using MCP tools

<rules>

<rule id="mcp-tool-failure">
  <constraint>If a task/command asks to use a specific MCP tool and the tool fails, DO NOT try to use an alternative.</constraint>
</rule>

## Umbraco MCP

<rule id="mcp-not-running">
  <constraint>If the Umbraco MCP tool is not running, DO NOT attempt to modify Umbraco content.</constraint>
</rule>

<rule id="mcp-website-down">
  <constraint>The Umbraco MCP tool may not work if the website is not running.</constraint>
  <action>If you determine the website is not running, start it and try again.</action>
</rule>

<rule id="mcp-failure-notify">
  <constraint>If the website is running and the MCP tool fails, notify the user. DO NOT attempt to complete ANY commands without it operating.</constraint>
</rule>

<rule id="no-direct-api">
  <constraint>NEVER use `curl`, `Invoke-RestMethod`, `Invoke-WebRequest`, or any other direct HTTP/API calls to access Umbraco. All Umbraco operations MUST go through the Umbraco MCP tools exclusively.</constraint>
  <reason>Do NOT attempt to work around MCP failures by calling the Umbraco API directly.</reason>
</rule>

## Server process management

<rule id="detach-not-stopped">
  <constraint>When the Umbraco web server is started with `dotnet run` using `detach: true`, the server process continues running independently even after the shell reports completion. A "detached shell completed" notification does NOT mean the server has stopped.</constraint>
</rule>

<rule id="no-restart-on-notification">
  <constraint>Do NOT restart the server when you receive a shell completion notification.</constraint>
  <action>Check if the server is actually responsive first (e.g., try navigating with Playwright or check for the dotnet process).</action>
</rule>

## Browser commands

<rule id="use-playwright">
  <constraint>Use the "playwright" MCP server for all browser commands.</constraint>
</rule>

- When navigating to browser URLs, use the `browser_navigate` command.
- When zooming in the browser, use `browser_evaluate` + javascript. Example: `document.body.style.zoom='75%'`
- When scrolling in the browser, use `browser_evaluate` + javascript. Example: `window.scrollTo(0, document.body.scrollHeight)` to scroll to the bottom, `window.scrollTo(0, 0)` to scroll to the top.
- When waiting for a page to load, use the `browser_wait_for` command.

### Closing the browser

<rule id="close-browser">
  <constraint>When you are done with browser commands, close the browser using the `browser_close` command.</constraint>
  <exception context="umbraco-demo">When the `umbraco-demo` agent is orchestrating a live demo, do NOT close the browser at any point — the browser window is visible to the live audience and must remain open throughout all steps and after the demo completes.</exception>
</rule>

</rules>
