# Copilot CLI custom agent templates

This directory contains agent profile templates for personal use with Copilot CLI.

## Project-level agents (auto-discovered)

Project agents that Copilot CLI discovers automatically from this repository live in `.github/agents/`:

- `umbraco-demo.agent.md` — end-to-end demo orchestrator (the main entry point)

You do not need to copy these — Copilot CLI loads them automatically from the project.

## Personal agent templates

The files in this directory (`.copilot/agents/`) are optional templates you can copy to your personal `~/.copilot/agents/` directory if you want them available across all repositories.

Included templates:

- `umbraco-site-builder.agent.md`
- `umbraco-site-validator.agent.md`

### How to install as personal agents

```bash
mkdir -p ~/.copilot/agents
cp .copilot/agents/*.agent.md ~/.copilot/agents/
```

Then restart Copilot CLI and use `/agent` to select them, or invoke them explicitly.
