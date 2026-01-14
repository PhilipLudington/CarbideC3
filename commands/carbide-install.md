# CarbideC3 Install

Install the CarbideC3 development framework into the current project.

## Instructions

1. **Clone CarbideC3** into the project:
   ```bash
   git clone https://github.com/PhilipLudington/CarbideC3.git carbide
   rm -rf carbide/.git
   ```

2. **Copy Claude Code integration**:
   ```bash
   mkdir -p .claude/commands .claude/rules
   cp carbide/commands/*.md .claude/commands/
   cp carbide/rules/*.md .claude/rules/
   ```

3. **Add CarbideC3 reference to CLAUDE.md**:

   If `./CLAUDE.md` doesn't exist, create it. Add the following:
   ```markdown
   ## C3 Development

   This project uses the CarbideC3 framework for C3 development standards.
   See `carbide/CARBIDE.md` for coding guidelines and available commands.
   ```

4. **Verify installation**:
   - Confirm `.claude/commands/` contains carbide-*.md files
   - Confirm `.claude/rules/` contains the rule files
   - Confirm `CLAUDE.md` references the CarbideC3 framework

## After Installation

The following commands are now available:
- `/carbide-init` - Initialize a new C3 project
- `/carbide-review` - Review code against standards
- `/carbide-safety` - Security-focused review
