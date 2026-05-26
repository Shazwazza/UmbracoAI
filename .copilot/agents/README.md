# Copilot CLI custom agent templates

This directory contains repository-tracked custom agent profiles for Copilot CLI.

## Included agents

- `umbraco-site-builder.agent.md`
- `umbraco-site-validator.agent.md`

## How to use in Copilot CLI

Copilot CLI discovers personal custom agents from `~/.copilot/agents`.

Copy these templates into your local personal agents directory:

```bash
mkdir -p ~/.copilot/agents
cp .copilot/agents/*.agent.md ~/.copilot/agents/
```

Then restart Copilot CLI and use `/agent` to select them, or call them explicitly.
