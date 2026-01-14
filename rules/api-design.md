# API Design Rules

## A1: Accept Slices for Input

Functions should accept slices, not pointers with lengths.

```c3
// WRONG
fn void process(char* data, usz len) { }

// CORRECT
fn void process(char[] data) { }
```

## A2: Use Optional Types for Nullable Returns

Never use sentinel values (-1, NULL) for "not found".

```c3
// WRONG
fn isz find(char[] haystack, char needle) {
    // Returns -1 if not found
}

// CORRECT
fn usz? find(char[] haystack, char needle) {
    foreach (i, c : haystack) {
        if (c == needle) return i;
    }
    return null;
}
```

## A3: Return Structs for Multiple Values

```c3
// WRONG - out parameters
fn void divide(int a, int b, int* q, int* r) { }

// CORRECT
struct DivResult { int quotient; int remainder; }
fn DivResult divide(int a, int b) {
    return { .quotient = a / b, .remainder = a % b };
}
```

## A4: Config Structs with Defaults

```c3
struct ServerConfig {
    ushort port = 8080;
    String host = "localhost";
    uint timeout_ms = 30_000;
    bool tls = false;
}

// Caller uses defaults or overrides
Server s1 = Server.init(alloc, {})!;
Server s2 = Server.init(alloc, { .port = 443, .tls = true })!;
```

## A5: Methods Return Self for Chaining

When sensible, methods can return `&self` for chaining.

```c3
fn &Builder Builder.set_name(&self, String name) {
    self.name = name;
    return self;
}

fn &Builder Builder.set_port(&self, ushort port) {
    self.port = port;
    return self;
}

// Usage
Builder b = Builder.init()
    .set_name("myserver")
    .set_port(8080);
```

## A6: Prefer Immutable by Default

Pass by value or const reference when mutation isn't needed.

```c3
// Read-only access
fn int calculate(Config config) { }    // By value (small struct)
fn int process(char[] data) { }        // Slice is already a view

// Mutation needed
fn void update(&self) { }              // Explicit &self
```

## A7: Use Distinct Types for Type Safety

```c3
// WRONG - easy to confuse
fn void create_user(uint id, uint org_id) { }
create_user(org_id, user_id);  // Oops! Swapped!

// CORRECT
typedef UserId = uint;
typedef OrgId = uint;
fn void create_user(UserId id, OrgId org_id) { }
// create_user(org_id, user_id);  // Compile error!
```

## A8: Document Ownership in Signatures

```c3
<* Caller owns returned slice. Free with same allocator. *>
fn char[]! duplicate(Allocator* alloc, char[] src) { }

<* Borrows internal buffer. Valid until next mutation. *>
fn char[] view(&self) { }

<* Takes ownership of `data`. Caller must not free. *>
fn void consume(char[] data) { }
```
