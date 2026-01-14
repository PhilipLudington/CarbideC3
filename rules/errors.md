# Error Handling Rules

## E1: Define Specific Faults

Create domain-specific faults, not generic ones.

```c3
// WRONG
faultdef FAILED;  // Meaningless

// CORRECT
faultdef PARSE_ERROR {
    INVALID_SYNTAX,
    UNEXPECTED_TOKEN,
    UNTERMINATED_STRING,
}

faultdef IO_ERROR {
    FILE_NOT_FOUND,
    PERMISSION_DENIED,
    DISK_FULL,
}
```

## E2: Use Optional Types for Fallible Functions

Functions that can fail return `Type?` or `void!`.

```c3
// Returns value or fault
fn int? parse_int(char[] input) {
    if (!is_numeric(input)) return INVALID_FORMAT?;
    return do_parse(input);
}

// Returns nothing or fault
fn void! write_file(String path, char[] data) {
    File f = open(path, WRITE)!;
    defer f.close();
    f.write(data)!;
}
```

## E3: Propagate with `!`

Use `!` to propagate errors up the call stack.

```c3
fn Document! load(String path) {
    char[] data = read_file(path)!;  // Propagates on error
    return parse(data)!;              // Propagates on error
}
```

## E4: Handle with `if (catch)`

Use `if (catch)` to handle specific errors.

```c3
fn void! connect_safe(Address addr) {
    Connection? conn = Connection.init(addr);

    if (catch err = conn) {
        switch (err) {
            case CONNECTION_REFUSED:
                log::warn("Connection refused, retrying...");
                return retry(addr);
            default:
                return err?;  // Re-raise
        }
    }

    use_connection(conn);
}
```

## E5: Default Values with `??`

Use `??` to provide fallback values.

```c3
fn int get_port(Config* cfg) {
    return cfg.get("port") ?? 8080;
}

fn String get_name(User? user) {
    return user?.name ?? "Anonymous";
}
```

## E6: Assert with `!!` Only for Programming Errors

Only use `!!` when failure indicates a bug.

```c3
// CORRECT: Known-good builtin config
Config cfg = load_builtin()!!;

// WRONG: User input can fail legitimately
Config cfg = load_user_config()!!;  // Don't crash on bad input!
```

## E7: Error Context via Wrapper Functions

Provide context by wrapping low-level errors.

```c3
faultdef CONFIG_ERROR {
    FILE_MISSING,
    PARSE_FAILED,
    INVALID_VALUE,
}

fn Config! load_config(String path) {
    char[]? data = read_file(path);
    if (catch data) return FILE_MISSING?;

    Config? cfg = parse(data);
    if (catch cfg) return PARSE_FAILED?;

    if (!validate(cfg)) return INVALID_VALUE?;

    return cfg;
}
```
