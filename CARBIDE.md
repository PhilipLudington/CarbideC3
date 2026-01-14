# CarbideC3 Quick Reference

> **AI-Optimized C3 Development Standards**

## Core Principles

1. **Leverage Optionals** — Use `?` types, never sentinel values
2. **Explicit Resource Management** — Every allocation has an owner
3. **Fail Loudly** — Never silently ignore faults
4. **Contracts for Invariants** — `@require`/`@ensure` for constraints
5. **Modules over Headers** — Clean namespaces, no preprocessor

---

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Types | PascalCase | `HttpClient` |
| Functions | snake_case | `read_file` |
| Variables | snake_case | `buffer_size` |
| Constants | UPPER_SNAKE | `MAX_SIZE` |
| Faults | UPPER_SNAKE | `PARSE_ERROR` |
| Modules | snake_case | `http_client` |

### Method Patterns

```c3
init() / deinit()         // Lifecycle
name() / set_name()       // Accessor / Mutator
is_ready() / has_value()  // Boolean queries
to_slice() / from_bytes() // Conversions
```

---

## Memory Rules

```c3
// M1: Accept allocator parameter
fn Item[]! create(Allocator* alloc)

// M2: defer immediately after acquire
char[] buf = alloc.alloc(char, 1024)!;
defer alloc.free(buf);

// M3: Error-path cleanup
Widget* w = alloc.new(Widget)!;
defer if (@catch) alloc.free(w);

// M4: Struct lifecycle
fn Connection! Connection.init(Allocator* a) { }
fn void Connection.deinit(&self) { }
```

---

## Error Handling

```c3
// E1: Specific faults
faultdef PARSE_ERROR { INVALID_SYNTAX, UNEXPECTED_TOKEN }

// E2: Propagate with !
Value val = do_something()!;

// E3: Default with ??
int port = config.get("port") ?? 8080;

// E4: Handle with if (catch)
if (catch err = result) {
    switch (err) {
        case NOT_FOUND: return default;
        default: return err?;
    }
}

// E5: Assert with !! (only for programming errors)
Config cfg = load_builtin()!!;
```

---

## API Design

```c3
// A1: Accept slices
fn void process(char[] data)

// A2: Optional for nullable
fn usz? find(char[] haystack, char needle)

// A3: Config structs with defaults
struct Config {
    ushort port = 8080;
    bool tls = false;
}
Server s = Server.init({.port = 443})!;

// A4: Return structs for multiple values
struct DivResult { int q; int r; }
fn DivResult divide(int a, int b)
```

---

## Contracts

```c3
<*
 * @param count : "Items to process"
 * @require count > 0 : "Must be positive"
 * @require count <= MAX : "Must not exceed max"
 * @return "Processed items"
 * @ensure return.len == count
 *>
fn Item[]! process(usz count)
```

---

## Security

```c3
// S1: Validate external input
if (input.len > MAX_SIZE) return TOO_LARGE?;

// S2: Use slices, not raw pointers
fn void process(char[] data)  // NOT char* data

// S3: Check integer overflow
if (a > uint.max - b) return OVERFLOW?;

// S4: Clear sensitive data
defer foreach (&c : password) *c = 0;
```

---

## Common Patterns

```c3
// Struct lifecycle
Connection c = Connection.init(alloc)!;
defer c.deinit();

// Iteration
foreach (item : items) { }
foreach (i, item : items) { }
foreach (&item : items) { *item = x; }

// Slicing
char[] slice = array[start..end];

// Temporary allocations
@pool() {
    char[] temp = mem::temp_alloc(char, 1024);
    // Auto-freed at block end
};
```

---

## Build Commands

```bash
c3c compile src/main.c3     # Compile
c3c run src/main.c3         # Compile and run
c3c test                    # Run tests
c3c build                   # Build project
```

---

## Slash Commands

| Command | Description |
|---------|-------------|
| `/carbide-init` | Create new project |
| `/carbide-review` | Code review |
| `/carbide-safety` | Security review |

---

*Explicit over implicit. Simple over clever. Safe over fast.*
