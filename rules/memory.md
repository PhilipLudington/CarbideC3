# Memory Management Rules

## M1: Accept Allocator Parameter

Functions that allocate memory MUST accept an allocator parameter.

```c3
// WRONG
fn char[]! read_file(String path) {
    // Hidden allocator - caller can't control memory
}

// CORRECT
fn char[]! read_file(Allocator* alloc, String path) {
    return alloc.alloc(char, size)!;
}
```

## M2: Defer Immediately After Acquisition

Place `defer` statements immediately after resource acquisition.

```c3
fn void! process(Allocator* alloc) {
    char[] buffer = alloc.alloc(char, 1024)!;
    defer alloc.free(buffer);  // IMMEDIATELY after alloc

    File f = open("data.txt")!;
    defer f.close();  // IMMEDIATELY after open

    // Use resources...
}
```

## M3: Use Conditional Defer for Error Cleanup

Use `defer if (@catch)` for cleanup that only runs on error path.

```c3
fn Widget*! create(Allocator* alloc) {
    Widget* w = alloc.new(Widget)!;
    defer if (@catch) alloc.free(w);  // Only on error

    w.buffer = alloc.alloc(char, 1024)!;
    defer if (@catch) alloc.free(w.buffer);  // Only on error

    w.init()!;
    return w;  // Success - no cleanup runs
}
```

## M4: Document Ownership

Always document who owns allocated memory.

```c3
<* Caller owns returned slice. Must free with same allocator. *>
fn char[]! duplicate(Allocator* alloc, char[] src) { }

<* Returns view into internal buffer. Valid until mutation. *>
fn char[] view(&self) { }
```

## M5: Use @pool for Temporary Allocations

Use `@pool()` for short-lived allocations that can be bulk-freed.

```c3
fn void! process_batch(Item[] items) {
    @pool() {
        foreach (item : items) {
            // Allocations here auto-freed at block end
            char[] temp = mem::temp_alloc(char, 1024);
            process(item, temp)!;
        }
    };
}
```

## M6: Struct Lifecycle Pattern

Structs with resources MUST have init/deinit methods.

```c3
struct Connection {
    Allocator* alloc;
    char[] buffer;
    Socket socket;
}

fn Connection! Connection.init(Allocator* alloc) {
    char[] buf = alloc.alloc(char, 4096)!;
    defer if (@catch) alloc.free(buf);

    Socket sock = Socket.connect()!;

    return { .alloc = alloc, .buffer = buf, .socket = sock };
}

fn void Connection.deinit(&self) {
    self.socket.close();
    self.alloc.free(self.buffer);
}
```
