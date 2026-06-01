---
description: Rules for using MCP tools
applyTo: '**/*'
---
# Rules for using MCP tools

## Common Rules

* If a task/command asks to use a specific MCP tool and the tool fails, DO NOT try to use an alternative.

## Umbraco MCP

* If the Umbraco MCP tool is not running, DO NOT attempt to modify Umbraco content.
* The Umbraco MCP tool may not work if the website is not running. If you determine the website is not running, you can proceed to start it and try again.
* If, the website is running and the MCP tool fails, notify the user, DO NOT attempt to complete ANY commands without it operating.

## Browser commands

- Use the "playwright" MCP server for browser commands.
- When navigating to browser URLs, use the "browser_navigate" mcp server command.
- When zooming in the browser, use the "browser_evaluate" mcp server command + javascript. Example: `document.body.style.zoom='75%'`
- When scrolling in the browser, use the "browser_evaluate" mcp server command + javascript. Example: `window.scrollTo(0, document.body.scrollHeight)` to scroll to the bottom of the page and `window.scrollTo(0, 0)` to scroll to the top of the page.
- When waiting for a period of time when loading web pages with "playwright", is the browser_wait_for command.

### Closing the browser

- When you are done with browser commands, close the browser using the "browser_close" mcp server command.
