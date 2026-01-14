# CarbideC3 Coding Standards

> **Hardened C3 Development Standards for AI-Assisted Programming**
>
> Version 1.0 | C3 0.7+

## Philosophy

**Explicit over implicit. Simple over clever. Safe over fast.**

CarbideC3 enables developers to write safe, maintainable, and trustworthy C3 code with AI assistance. These standards are designed to be unambiguous—both for humans and AI systems.

### Core Principles

1. **Leverage Optionals** — Use `?` types for fallible operations, never sentinel values
2. **Explicit Resource Management** — Every allocation has an owner and a cleanup path via `defer`
3. **Fail Loudly** — Faults should be visible and handled, never silently ignored
4. **Contracts for Invariants** — Use `@require`/`@ensure` to document and enforce constraints
5. **Modules over Headers** — Clean namespace organization, no preprocessor hacks

---

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Memory Management](#2-memory-management)
3. [Error Handling](#3-error-handling)
4. [API Design](#4-api-design)
5. [Code Organization](#5-code-organization)
6. [Documentation](#6-documentation)
7. [Testing](#7-testing)
8. [Contracts](#8-contracts)
9. [Macros and Generics](#9-macros-and-generics)
10. [Security and Safety](#10-security-and-safety)
11. [C Interop](#11-c-interop)
12. [Quick Reference](#12-quick-reference)

---

## 1. Naming Conventions

### 1.1 General Rules

C3 enforces that user-defined types start with uppercase letters.

| Element | Style | Example |
|---------|-------|---------|
| Types, structs, enums | PascalCase | `HttpClient`, `ParseError` |
| Functions | snake_case | `read_file`, `parse_header` |
| Variables, fields | snake_case | `buffer_size`, `is_ready` |
| Constants | UPPER_SNAKE_CASE | `MAX_BUFFER_SIZE` |
| Modules | snake_case | `http_client`, `json_parser` |

### 1.2 Function Naming Patterns

```c3
// Initialization/deinitialization
fn HttpClient init(Allocator* alloc) { }
fn void HttpClient.deinit(&self) { }

// Getters - no prefix for simple accessors
fn String HttpClient.name(&self) { }
fn bool HttpClient.is_ready(&self) { }
fn bool HttpClient.has_value(&self) { }

// Setters - use "set_" prefix
fn void HttpClient.set_name(&self, String name) { }

// Actions - verb first
fn void! HttpClient.connect(&self) { }
fn usz! HttpClient.read_bytes(&self, char[] buffer) { }
fn void! HttpClient.write_all(&self, char[] data) { }

// Conversions
fn char[] HttpClient.to_slice(&self) { }
fn HttpClient! from_bytes(char[] bytes) { }

// Fallible creation
fn HttpClient*! create(Allocator* alloc) { }
fn void HttpClient.destroy(&self) { }
```

### 1.3 Type Naming

```c3
// Structs - noun, describes what it is
struct HttpClient { }
struct ParseResult { }
struct BufferWriter { }

// Enums - noun, often singular
enum Status { PENDING, ACTIVE, COMPLETE }
enum FileMode { READ, WRITE, READ_WRITE }

// Fault definitions - UPPER_SNAKE_CASE
faultdef INVALID_SYNTAX, UNEXPECTED_TOKEN, OUT_OF_MEMORY;
faultdef FILE_NOT_FOUND, PERMISSION_DENIED, IO_ERROR;

// Distinct types - PascalCase
typedef UserId = uint;
typedef Timestamp = long;
```

### 1.4 File and Module Naming

```
src/
├── http_client.c3      # snake_case for file names
├── json_parser.c3
├── string_utils.c3
└── main.c3
```

```c3
// Module matches file name
module http_client;
module json_parser;
module string_utils;
```

### 1.5 Naming Clarity

```c3
// BAD: Ambiguous
char[] data;
int temp;
bool flag;

// GOOD: Descriptive
char[] response_buffer;
int retry_count;
bool is_connected;
```

---

## 2. Memory Management

### 2.1 Allocator Rules

**M1: Accept an allocator parameter for functions that allocate.**

```c3
// BAD: Hidden allocator dependency
fn Config! load_config() {
    char[] file = read_file_alloc("config.json");  // What allocator?
    // ...
}

// GOOD: Explicit allocator
fn Config! load_config(Allocator* alloc, String path) {
    char[] file = alloc.alloc(char, 1024)!;
    defer alloc.free(file);
    // ...
}
```

**M2: Use defer for cleanup immediately after acquisition.**

```c3
fn void! process_file(Allocator* alloc, String path) {
    File file = open(path, READ)!;
    defer file.close();  // Immediately after open

    char[] contents = alloc.alloc(char, file.size())!;
    defer alloc.free(contents);  // Immediately after alloc

    process(contents)!;
}
```

**M3: Document ownership in function signatures.**

```c3
<* Caller owns the returned slice and must free it. *>
fn char[]! duplicate(Allocator* alloc, char[] source) {
    return alloc.alloc_init(char, source);
}

<* Returns a slice into the internal buffer. Valid until next mutation. *>
fn char[] view(&self) {
    return self.buffer[0..self.len];
}
```

### 2.2 Struct Lifecycle

```c3
struct Connection {
    Allocator* allocator;
    char[] buffer;
    Socket socket;
}

<* Initialize a new connection. Caller must call deinit(). *>
fn Connection! Connection.init(Allocator* alloc, Address addr) {
    char[] buffer = alloc.alloc(char, 4096)!;
    defer if (@catch) alloc.free(buffer);

    Socket socket = Socket.connect(addr)!;
    // No defer needed - if we get here, we succeed

    return Connection {
        .allocator = alloc,
        .buffer = buffer,
        .socket = socket,
    };
}

<* Release all resources. *>
fn void Connection.deinit(&self) {
    self.socket.close();
    self.allocator.free(self.buffer);
}
```

### 2.3 Temporary Allocator Pattern

```c3
fn void! process_many(Item[] items) {
    // Use temporary allocator for short-lived allocations
    @pool() {
        foreach (item : items) {
            char[] temp = mem::temp_alloc(char, 1024);
            // temp is automatically freed at end of @pool
            process_item(item, temp)!;
        }
    };
}
```

---

## 3. Error Handling

### 3.1 Fault Definitions

**E1: Define specific faults for each domain.**

```c3
// BAD: Generic fault
faultdef FAILED;  // What failed? Why?

// GOOD: Specific faults
faultdef PARSE_ERROR {
    INVALID_SYNTAX,
    UNEXPECTED_TOKEN,
    UNTERMINATED_STRING,
    NESTING_TOO_DEEP,
}

faultdef IO_ERROR {
    FILE_NOT_FOUND,
    PERMISSION_DENIED,
    DISK_FULL,
}
```

### 3.2 Optional Types

**E2: Use optional types (`?`) for fallible operations.**

```c3
// Function that can fail returns Type?
fn double? divide(int a, int b) {
    if (b == 0) return DIVISION_BY_ZERO?;
    return (double)a / (double)b;
}

// Void function that can fail returns void!
fn void! write_file(String path, char[] data) {
    File f = open(path, WRITE)!;  // Propagate on error
    defer f.close();
    f.write(data)!;
}
```

### 3.3 Error Handling Patterns

**Pattern: Propagation with `!`**

```c3
fn Document! load_and_parse(Allocator* alloc, String path) {
    char[] contents = read_file(alloc, path)!;  // Propagates error
    defer alloc.free(contents);

    return parse(alloc, contents)!;  // Propagates error
}
```

**Pattern: Handle with `if (catch)`**

```c3
fn Connection! connect_with_retry(Address addr, uint max_retries) {
    for (uint attempts = 0; attempts < max_retries; attempts++) {
        Connection? conn = Connection.init(addr);

        if (catch err = conn) {
            if (err == CONNECTION_REFUSED) {
                sleep(1000);
                continue;
            }
            return err?;  // Re-raise other errors
        }
        return conn;  // Success
    }
    return MAX_RETRIES_EXCEEDED?;
}
```

**Pattern: Default value with `??`**

```c3
fn int get_port(Config* config) {
    // Use default if lookup fails
    return config.get_int("port") ?? 8080;
}
```

**Pattern: Assert success with `!!`**

```c3
fn void init_known_good() {
    // Only use !! when failure is a programming error
    Config config = load_builtin_config()!!;
}
```

### 3.4 Cleanup on Error

```c3
fn Widget*! create_widget(Allocator* alloc) {
    Widget* widget = alloc.new(Widget)!;

    // defer with @catch only runs on error path
    defer if (@catch) alloc.free(widget);

    widget.buffer = alloc.alloc(char, 1024)!;
    defer if (@catch) alloc.free(widget.buffer);

    widget.handle = acquire_handle()!;
    // No cleanup needed - if we get here, we succeed

    return widget;
}
```

---

## 4. API Design

### 4.1 Function Signatures

**A1: Accept slices for input buffers.**

```c3
// BAD: Requires specific pointer type
fn ulong hash(char* data, usz len) { }

// GOOD: Flexible slice
fn ulong hash(char[] data) { }
```

**A2: Use optional types for nullable values.**

```c3
// BAD: Magic values
fn isz find(char[] haystack, char needle) {
    // Returns -1 if not found
}

// GOOD: Optional type
fn usz? find(char[] haystack, char needle) {
    foreach (i, c : haystack) {
        if (c == needle) return i;
    }
    return null;
}
```

**A3: Return structs for multiple values.**

```c3
// BAD: Out parameters
fn void divide(int a, int b, int* quotient, int* remainder) { }

// GOOD: Return struct
struct DivResult { int quotient; int remainder; }

fn DivResult divide(int a, int b) {
    return { .quotient = a / b, .remainder = a % b };
}
```

### 4.2 Configuration Structs

```c3
struct ServerConfig {
    ushort port = 8080;
    String host = "localhost";
    uint timeout_ms = 30_000;
    uint max_connections = 100;
    bool tls_enabled = false;
}

// Usage with defaults
Server server = Server.init(alloc, {})!;

// Override specific fields
Server server = Server.init(alloc, {
    .port = 443,
    .tls_enabled = true,
})!;
```

### 4.3 Methods on Types

```c3
struct Buffer {
    char[] data;
    usz len;
    Allocator* alloc;
}

// Methods use Type.method_name pattern
fn void Buffer.clear(&self) {
    self.len = 0;
}

fn void! Buffer.append(&self, char[] bytes) {
    if (self.len + bytes.len > self.data.len) {
        return BUFFER_OVERFLOW?;
    }
    self.data[self.len..self.len + bytes.len] = bytes;
    self.len += bytes.len;
}

fn char[] Buffer.slice(&self) {
    return self.data[0..self.len];
}
```

---

## 5. Code Organization

### 5.1 File Structure

```c3
/**
 * JSON Parser Module
 *
 * A streaming JSON parser with low memory overhead.
 */
module json_parser;

import std::io;
import std::collections::list;

// Local imports
import utils;
import config;

// Constants
const usz MAX_DEPTH = 64;
const usz BUFFER_SIZE = 4096;

// Type definitions
struct Parser { ... }

faultdef PARSE_ERROR { ... }

// Public functions
fn Parser Parser.init(Allocator* alloc) { ... }

// Private functions
fn void internal_helper() @private { ... }
```

### 5.2 Module Organization

```c3
// Main module exports public API
module mylib;

// Re-export submodules
public import mylib::parser;
public import mylib::writer;

// Module-level types
struct Config { ... }
```

### 5.3 Project Layout

```
project/
├── project.json        # Build configuration
├── src/
│   ├── main.c3         # Entry point
│   ├── lib.c3          # Library root
│   ├── parser.c3
│   └── utils.c3
├── test/
│   └── parser_test.c3
└── vendor/             # Dependencies
```

---

## 6. Documentation

### 6.1 Doc Comments

```c3
<*
 * Parses the input string into an AST.
 *
 * The returned AST is owned by the caller and must be freed by calling
 * `deinit()` when no longer needed.
 *
 * @param alloc : "Allocator for AST nodes"
 * @param source : "Source code to parse"
 * @return "Parsed AST, or fault on error"
 *
 * Example:
 * ```
 * Ast ast = parser.parse(alloc, source)!;
 * defer ast.deinit();
 * ```
 *>
fn Ast! Parser.parse(&self, Allocator* alloc, char[] source) {
    // ...
}
```

### 6.2 When to Document

- **Always**: Public functions, types, and fields
- **Always**: Complex algorithms or non-obvious logic
- **Always**: Safety requirements and invariants
- **Always**: Contracts and their rationale
- **Skip**: Obvious getter/setter pairs
- **Skip**: Self-explanatory one-liners

---

## 7. Testing

### 7.1 Test Organization

```c3
module parser_test;

import parser;
import std::testing;

fn void! test_basic_parse() @test {
    Parser p = Parser.init();
    defer p.deinit();

    Ast ast = p.parse("{}")!;
    testing::assert(ast.kind == OBJECT);
}

fn void! test_invalid_input() @test {
    Parser p = Parser.init();
    defer p.deinit();

    Ast? result = p.parse("{invalid");
    testing::assert(@catch(result) == INVALID_SYNTAX);
}
```

### 7.2 Test Naming

```c3
// Pattern: "test_subject_behavior_condition"
fn void! test_parser_parses_empty_object() @test { }
fn void! test_parser_returns_error_on_invalid_input() @test { }
fn void! test_connection_reconnects_after_timeout() @test { }
fn void! test_buffer_grows_when_capacity_exceeded() @test { }
```

### 7.3 Table-Driven Tests

```c3
fn void! test_parse_integers() @test {
    struct TestCase {
        char[] input;
        long? expected;
    }

    TestCase[] cases = {
        { .input = "0", .expected = 0 },
        { .input = "42", .expected = 42 },
        { .input = "-1", .expected = -1 },
        { .input = "abc", .expected = null },
    };

    foreach (case : cases) {
        long? result = parse_int(case.input);
        testing::assert_eq(result, case.expected);
    }
}
```

---

## 8. Contracts

### 8.1 Using Contracts

```c3
<*
 * @param count : "Number of items to process"
 * @require count > 0 : "Count must be positive"
 * @require count <= MAX_ITEMS : "Count exceeds maximum"
 * @return "Processed items"
 * @ensure return.len == count : "Output matches requested count"
 *>
fn Item[]! process_items(usz count) {
    // Contract violations are caught at runtime (debug) or compile-time
    // ...
}
```

### 8.2 Contract Guidelines

```c3
// C1: Use @require for preconditions on inputs
<* @require buffer.len >= MIN_SIZE *>
fn void! write(char[] buffer) { }

// C2: Use @ensure for postconditions on outputs
<* @ensure return >= 0 *>
fn int abs(int value) { }

// C3: Document contracts with string descriptions
<* @require port != 0 : "Port cannot be zero" *>
fn void! bind(ushort port) { }

// C4: Contracts should be checkable
// BAD: Uncheckable
<* @require "buffer is valid" *>  // How to check?

// GOOD: Checkable
<* @require buffer.len > 0 *>
```

---

## 9. Macros and Generics

### 9.1 Generic Types

```c3
struct Stack(<Type>) {
    Type[] items;
    usz capacity;
    usz size;
    Allocator* alloc;
}

fn void! Stack.push(&self, Type item) {
    if (self.size >= self.capacity) {
        return STACK_OVERFLOW?;
    }
    self.items[self.size++] = item;
}

fn Type? Stack.pop(&self) {
    if (self.size == 0) return null;
    return self.items[--self.size];
}

// Usage
Stack(<int>) int_stack;
Stack(<String>) string_stack;
```

### 9.2 Compile-Time Macros

```c3
// Simple expression macro
macro square(x) {
    return x * x;
}

// Code-generating macro with # prefix for AST params
macro @swap(#a, #b) {
    var temp = #a;
    #a = #b;
    #b = temp;
}

// Type-aware macro
macro @typeof(#expr) {
    return $typeof(#expr);
}
```

### 9.3 Macro Guidelines

```c3
// G1: Prefer functions over macros when possible
// BAD: Macro for simple operation
macro add(a, b) { return a + b; }

// GOOD: Regular function
fn int add(int a, int b) { return a + b; }

// G2: Use macros for code that needs AST manipulation
// GOOD: Macro for swap (modifies arguments)
macro @swap(#a, #b) { ... }

// G3: Use $typeof, $sizeof, etc. for compile-time introspection
macro debug_print(#value) {
    io::printfn("%s = %s", $stringify(#value), #value);
}
```

---

## 10. Security and Safety

### 10.1 Input Validation

**S1: Validate all external input at boundaries.**

```c3
fn ushort! parse_port(char[] input) {
    ushort? value = parse_uint(input);

    if (catch value) {
        return INVALID_PORT?;
    }

    if (value == 0) {
        return PORT_ZERO_NOT_ALLOWED?;
    }

    return value;
}
```

**S2: Limit buffer sizes and counts.**

```c3
const usz MAX_HEADER_SIZE = 8 * 1024;  // 8KB
const usz MAX_HEADER_COUNT = 100;

fn Headers! parse_headers(char[] input) {
    if (input.len > MAX_HEADER_SIZE) {
        return HEADER_TOO_LARGE?;
    }
    // ...
}
```

### 10.2 Memory Safety

```c3
// S3: Use slices instead of raw pointers
// BAD: Raw pointer arithmetic
fn void process(char* data, usz len) {
    for (usz i = 0; i < len; i++) {
        // No bounds checking
    }
}

// GOOD: Slice with bounds checking
fn void process(char[] data) {
    foreach (c : data) {
        // Bounds checked automatically
    }
}

// S4: Use defer for resource cleanup
fn void! risky_operation() {
    Resource r = acquire()!;
    defer r.release();  // Always runs

    do_work(r)!;  // Even if this fails
}
```

### 10.3 Integer Safety

```c3
// S5: Check for overflow on arithmetic
fn uint! safe_add(uint a, uint b) {
    if (a > uint.max - b) {
        return OVERFLOW?;
    }
    return a + b;
}

// S6: Use appropriate sized types
typedef FileSize = ulong;  // Not int!
typedef Port = ushort;     // 0-65535
```

---

## 11. C Interop

### 11.1 Calling C Functions

```c3
module my_module;

// Declare C function
extern fn int puts(char* s);

// Or import C header
import libc;

fn void example() {
    libc::printf("Hello from C3\n");
}
```

### 11.2 Exposing to C

```c3
// Make function callable from C
fn int my_function(int x) @export("my_function") {
    return x * 2;
}

// Make struct C-compatible
struct CCompatible @packed {
    int x;
    int y;
}
```

### 11.3 C Interop Guidelines

```c3
// I1: Wrap C functions in safe C3 interfaces
// C function (unsafe)
extern fn char* getenv(char* name);

// Safe wrapper
fn char[]? get_env(char[] name) {
    char* result = getenv(name.ptr);
    if (result == null) return null;
    return result[0..strlen(result)];
}

// I2: Convert C strings to slices at boundaries
fn void process_c_string(char* c_str) {
    char[] safe_slice = c_str[0..strlen(c_str)];
    process_safely(safe_slice);
}

// I3: Use @export for C-visible symbols
fn int api_function(int x) @export("mylib_function") {
    return internal_function(x);
}
```

---

## 12. Quick Reference

### Naming At-a-Glance

| What | Style | Example |
|------|-------|---------|
| Type | PascalCase | `HttpClient` |
| Function | snake_case | `parse_header` |
| Variable | snake_case | `buffer_size` |
| Constant | UPPER_SNAKE | `MAX_SIZE` |
| Module | snake_case | `http_client` |
| Fault | UPPER_SNAKE | `PARSE_ERROR` |

### Common Patterns

```c3
// Struct lifecycle
Connection conn = Connection.init(alloc)!;
defer conn.deinit();

// Error handling
Value value = fallible_function()!;        // Propagate
Value value = fallible_function() ?? default;  // Default
Value value = fallible_function()!!;       // Assert success

if (catch err = result) { handle(err); }   // Handle error
if (try value = result) { use(value); }    // Handle success

// Cleanup
defer cleanup();                           // Always runs

// Slices
char[] slice = array[start..end];
foreach (item : slice) { }
foreach (i, item : slice) { }
foreach (&item : slice) { *item = x; }     // By reference
```

### Common Faults

```c3
faultdef COMMON_ERRORS {
    OUT_OF_MEMORY,
    INVALID_ARGUMENT,
    NOT_FOUND,
    TIMEOUT,
    CONNECTION_REFUSED,
}
```

### Build Commands

```bash
c3c compile src/main.c3     # Compile
c3c run src/main.c3         # Compile and run
c3c test                    # Run tests
c3c build                   # Build project
```

---

*CarbideC3 Standards v1.0 — Hardened C3 for AI-Assisted Development*

Sources:
- [C3 Language](https://c3-lang.org/)
- [C3 Tutorial](https://learn-c3.org/)
- [C3 GitHub](https://github.com/c3lang/c3c)
