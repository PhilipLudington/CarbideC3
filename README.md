# CarbideC3

> **Hardened C3 Development Standards for AI-Assisted Programming**

CarbideC3 provides coding standards, Claude Code rules, and tooling for writing safe, maintainable C3 code with AI assistance.

## Quick Start

### Using CarbideC3 Commands (No Setup Required)

These commands work on any C3 code:

```
/carbide-review path/to/file.c3    # Review code against CarbideC3 standards
/carbide-safety path/to/file.c3    # Security-focused review
```

### Creating a CarbideC3 Project

```
/carbide-init my-project           # Create new project with scaffold
cd my-project
c3c build                          # Compile
c3c test                           # Run tests
```

### Adding CarbideC3 to an Existing Project

1. **Copy the install command** to your project:
   ```bash
   mkdir -p .claude/commands
   curl -o .claude/commands/carbide-install.md https://raw.githubusercontent.com/PhilipLudington/CarbideC3/main/commands/carbide-install.md
   ```

2. **Run the install command** in Claude Code:
   ```
   /carbide-install
   ```

Once set up, use the CarbideC3 slash commands:
```
/carbide-review src/main.c3       # Review against standards
/carbide-update                   # Update to latest version
```

## Documentation

- **[STANDARDS.md](STANDARDS.md)** - Complete coding standards
- **[CARBIDE.md](CARBIDE.md)** - Quick reference card
- **[rules/](rules/)** - Individual rule files

## Core Principles

1. **Leverage Optionals** — Use `?` types for fallible operations
2. **Explicit Resource Management** — Every allocation has an owner
3. **Fail Loudly** — Faults should be visible and handled
4. **Contracts for Invariants** — Use `@require`/`@ensure`
5. **Modules over Headers** — Clean namespace organization

## Rules Categories

| Category | Description |
|----------|-------------|
| [memory.md](rules/memory.md) | Allocator patterns, defer, ownership |
| [errors.md](rules/errors.md) | Faults, optionals, error handling |
| [naming.md](rules/naming.md) | Naming conventions |
| [api-design.md](rules/api-design.md) | Function signatures, config structs |
| [contracts.md](rules/contracts.md) | @require, @ensure patterns |
| [security.md](rules/security.md) | Input validation, memory safety |

## Slash Commands

| Command | Description |
|---------|-------------|
| `/carbide-install` | Install CarbideC3 into a project |
| `/carbide-update` | Update CarbideC3 to latest version |
| `/carbide-init` | Initialize a new CarbideC3 project |
| `/carbide-review` | Comprehensive code review |
| `/carbide-safety` | Security-focused review |

## Example

```c3
module example;

import std::io;

faultdef EXAMPLE_ERROR { INVALID_INPUT, OVERFLOW }

<*
 * Process a value safely.
 * @param value : "Input value to process"
 * @require value >= 0 : "Value must be non-negative"
 * @return "Processed value or fault"
 *>
fn int? process(int value) {
    if (value < 0) return INVALID_INPUT?;
    if (value > 1000) return OVERFLOW?;
    return value * 2;
}

fn void main() {
    int result = process(42) ?? 0;
    io::printfn("Result: %d", result);
}
```

## License

MIT

## References

- [C3 Language](https://c3-lang.org/)
- [C3 Tutorial](https://learn-c3.org/)
- [C3 GitHub](https://github.com/c3lang/c3c)
