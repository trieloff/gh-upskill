![Upskill – Install Agent Skills](hero-banner.jpeg)

# upskill

[![24% Vibe_Coded](https://img.shields.io/badge/24%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

[![Vibe_Coded](https://img.shields.io/badge/Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

Quickly install Claude/Agent skills from another repository. Works standalone and as a `gh` extension.

## Install

- Standalone
  - macOS/Linux: `curl -fsSL https://raw.githubusercontent.com/trieloff/gh-upskill/main/install.sh | bash`
  - Custom prefix: `curl -fsSL https://raw.githubusercontent.com/trieloff/gh-upskill/main/install.sh | bash -s -- --prefix ~/.local`

- GitHub CLI extension
  - `gh extension install trieloff/gh-upskill`
  - Then run via `gh upskill ...` (or use `upskill` directly)

## Usage

### Install from repositories with `.claude/skills` directory

Install all skills from another repo (same syntax as `gh repo clone`):

```
upskill adobe/helix-website -b agent-skills
```

### Install from repositories with individual SKILL.md files

For repositories like `anthropics/skills` that don't have a `.claude/skills` directory, you can:

**List available skills:**
```
upskill anthropics/skills --list
```

**Install specific skills:**
```
upskill anthropics/skills --skill pdf --skill xlsx
```

**Install all skills:**
```
upskill anthropics/skills --all
```

### Install skills globally (personal skills)

Use the `-g` or `--global` flag to install skills to `~/.claude/skills` instead of the project's `.claude/skills` directory. Personal skills are available across all your Claude Code projects:

**Install globally:**
```
upskill -g anthropics/skills --skill pdf --skill xlsx
```

When installing globally:
- Skills are installed to `~/.claude/skills`
- `.agents/discover-skills` and `AGENTS.md` are not modified (since these are project-specific)
- The `-i` flag is ignored (no gitignore updates needed)

### What this does:
- Creates a temp directory and `gh repo clone`s the source repository
- For repos with `.claude/skills`: copies everything into `./.claude/skills`
- For repos with `SKILL.md` files: discovers and copies selected skills
- Creates `./.agents/discover-skills` (robust, shellcheck-friendly)
- Adds or updates a Skills section in `./AGENTS.md` with clear start/end markers
  - Ensures repeated runs do not duplicate the section

### Options:
- `-g, --global`: install skills to `~/.claude/skills` (personal skills available across all projects)
- `-b, --branch <branch>`: use a specific branch, tag, or commit
- `--skills-path <path>`: change source skills path (default: `.claude/skills`)
- `--list`: list available skills without installing
- `--skill <name>`: install specific skill(s) (can be used multiple times)
- `--all`: install all skills from SKILL.md files
- `-i`: add created files to `.gitignore` (`.claude/skills/` and `.agents/discover-skills`), idempotent via markers

## Idempotent AGENTS.md updates

The Skills section is inserted between markers. If present, it is replaced in-place:

```
<!-- upskill:skills:start -->
... Skills content ...
<!-- upskill:skills:end -->
```

## Discover skills

After installing, list available skills in your project:

```
./.agents/discover-skills
```

This safely scans both project skills (`.claude/skills/**/SKILL.md`) and personal skills (`~/.claude/skills/**/SKILL.md`), handling spaces correctly and printing names/paths/descriptions organized by location.

## Development

- Lint: `make lint` (shellcheck)
- Test: `make test` (network required for `gh repo clone`)
- CI runs lint + tests on pushes/PRs to `main`.

## Notes

- Requires `gh` CLI for cloning, `git`, and standard Unix tools.
- If the source AGENTS.md does not contain a `## Skills` section, the update is skipped.
- The generated `./.agents/discover-skills` improves robustness over the reference script (handles spaces; strict mode).

## Related Projects

Part of the **[AI Ecoverse](https://github.com/trieloff/ai-ecoverse)** - a comprehensive ecosystem of tools for AI-assisted development:
- [yolo](https://github.com/trieloff/yolo) - AI CLI launcher with worktree isolation
- [ai-aligned-git](https://github.com/trieloff/ai-aligned-git) - Git wrapper for safe AI commit practices
- [ai-aligned-gh](https://github.com/trieloff/ai-aligned-gh) - GitHub CLI wrapper for proper AI attribution
- [vibe-coded-badge-action](https://github.com/trieloff/vibe-coded-badge-action) - Badge showing AI-generated code percentage
- [gh-workflow-peek](https://github.com/trieloff/gh-workflow-peek) - Smarter GitHub Actions log filtering
- [as-a-bot](https://github.com/trieloff/as-a-bot) - GitHub App token broker for proper AI attribution
