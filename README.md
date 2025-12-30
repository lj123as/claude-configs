# My Claude Code Skills

A curated collection of Claude Code skills organized by application domain, combining custom skills with curated upstream skills.

## Directory Structure

```
my-skills/
├── SOURCES.yaml                    # Upstream source configuration
├── scripts/
│   └── sync-upstream.sh            # Script to sync from upstream repos
│
├── development/                    # Development & programming
│   ├── _custom/                    # Your own skills
│   └── _upstream/                  # Skills from upstream repos
│       └── mcp-builder/            # Each has .source.yaml for tracking
│
├── finance/                        # Financial tools
│   ├── _custom/
│   └── _upstream/
│
├── writing/                        # Content creation
├── data-analysis/                  # Data processing
├── automation/                     # Workflow automation
├── research/                       # Research tools
└── design/                         # Design & creative
```

## Quick Start

### Clone Entire Repository
```bash
cd .claude/skills
git clone https://github.com/lj123as/my-skill.git
```

### Clone Only Specific Category (Sparse Checkout)
```bash
cd .claude/skills
git clone --filter=blob:none --sparse https://github.com/lj123as/my-skill.git
cd my-skill
git sparse-checkout set development    # Only get development skills
# Or multiple categories:
git sparse-checkout set development finance automation
```

## Skill Categories

### Development (`development/`)
Skills for software development, MCP server creation, and tooling.

| Skill | Source | Description |
|-------|--------|-------------|
| mcp-builder | upstream | Guide for creating high-quality MCP servers |

### Finance (`finance/`)
Skills for financial analysis and tools. (Coming soon)

### Writing (`writing/`)
Skills for content creation and documentation. (Coming soon)

### Data Analysis (`data-analysis/`)
Skills for data processing and visualization. (Coming soon)

### Automation (`automation/`)
Skills for workflow automation. (Coming soon)

### Research (`research/`)
Skills for research and knowledge management. (Coming soon)

### Design (`design/`)
Skills for UI/UX and creative workflows. (Coming soon)

## Managing Skills

### Adding Your Own Skill
1. Create skill folder in `<category>/_custom/your-skill-name/`
2. Add `SKILL.md` with skill documentation
3. Add any supporting files (scripts, references, etc.)

### Syncing Upstream Skills
```bash
# Check for updates
./scripts/sync-upstream.sh --check

# Sync specific skill
./scripts/sync-upstream.sh mcp-builder

# Sync all enabled skills
./scripts/sync-upstream.sh --all

# List tracked skills
./scripts/sync-upstream.sh --list
```

### Adding New Upstream Skill
1. Edit `SOURCES.yaml` to add skill mapping
2. Run sync script: `./scripts/sync-upstream.sh <skill-name>`
3. Skill will be downloaded with `.source.yaml` tracking file

## Source Tracking

Each upstream skill contains a `.source.yaml` file that tracks:
- Original repository and path
- Commit hash when synced
- License information
- Any local modifications

**Important:** Do not delete `.source.yaml` files - they ensure license compliance.

## License

- **Custom skills (`_custom/`)**: Your choice of license
- **Upstream skills (`_upstream/`)**: See individual `.source.yaml` files
  - Most are Apache-2.0 from [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)

## Upstream Sources

| Repository | License | Description |
|------------|---------|-------------|
| [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | Apache-2.0 | Curated Claude Code skills |

## Contributing

1. **Custom skills**: Add to `_custom/` folder in appropriate category
2. **Upstream suggestions**: Edit `SOURCES.yaml` and submit PR
3. Keep skills focused and well-documented
