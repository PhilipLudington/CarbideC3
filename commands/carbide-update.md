# CarbideC3 Update

Update the CarbideC3 framework to the latest version.

## Instructions

1. **Remove the old CarbideC3 directory**:
   ```bash
   rm -rf carbide
   ```

2. **Clone the latest version**:
   ```bash
   git clone https://github.com/PhilipLudington/CarbideC3.git carbide
   rm -rf carbide/.git
   ```

3. **Update Claude Code integration**:
   ```bash
   cp carbide/commands/*.md .claude/commands/
   cp carbide/rules/*.md .claude/rules/
   ```

4. **Verify update**:
   - Confirm `.claude/commands/` and `.claude/rules/` are updated
