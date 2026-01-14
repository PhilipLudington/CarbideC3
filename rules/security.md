# Security Rules

## S1: Validate All External Input

Never trust data from outside your program.

```c3
fn ushort! parse_port(char[] input) {
    // Validate format
    if (input.len == 0 || input.len > 5) {
        return INVALID_PORT?;
    }

    // Validate content
    foreach (c : input) {
        if (c < '0' || c > '9') return INVALID_PORT?;
    }

    // Validate range
    uint value = parse_uint(input) ?? return INVALID_PORT?;
    if (value > 65535) return INVALID_PORT?;

    return (ushort)value;
}
```

## S2: Limit Buffer and Collection Sizes

Always enforce maximum sizes.

```c3
const usz MAX_REQUEST_SIZE = 1024 * 1024;  // 1MB
const usz MAX_HEADER_COUNT = 100;

fn Request! parse_request(char[] data) {
    if (data.len > MAX_REQUEST_SIZE) {
        return REQUEST_TOO_LARGE?;
    }
    // ...
}
```

## S3: Use Slices, Not Raw Pointers

Slices provide bounds checking.

```c3
// WRONG - no bounds checking
fn void process(char* data, usz len) {
    for (usz i = 0; i < len; i++) {
        use(data[i]);  // Could overflow
    }
}

// CORRECT - bounds checked
fn void process(char[] data) {
    foreach (c : data) {
        use(c);  // Safe
    }
}
```

## S4: Check Integer Overflow

Validate arithmetic operations on untrusted input.

```c3
fn usz! safe_multiply(usz a, usz b) {
    if (b != 0 && a > usz.max / b) {
        return OVERFLOW?;
    }
    return a * b;
}

fn usz! safe_add(usz a, usz b) {
    if (a > usz.max - b) {
        return OVERFLOW?;
    }
    return a + b;
}
```

## S5: Clear Sensitive Data

Zero memory containing secrets before freeing.

```c3
fn void! authenticate(char[] password) {
    defer {
        // Clear password from memory
        foreach (&c : password) {
            *c = 0;
        }
    }

    // Use password...
}
```

## S6: Avoid Format String Vulnerabilities

Never use untrusted input as format strings.

```c3
// WRONG - user controls format
fn void log_message(char[] user_input) {
    io::printf(user_input);  // Format string attack!
}

// CORRECT - fixed format
fn void log_message(char[] user_input) {
    io::printf("%s", user_input);
}
```

## S7: Path Traversal Prevention

Validate file paths from user input.

```c3
fn File! open_user_file(char[] filename) {
    // Reject path traversal attempts
    if (contains(filename, "..") || contains(filename, "/")) {
        return INVALID_PATH?;
    }

    // Construct safe path
    char[256] path;
    sprintf(path, "./uploads/%s", filename);
    return open(path, READ);
}
```

## S8: SQL/Command Injection Prevention

Never interpolate user input into commands.

```c3
// WRONG - SQL injection
fn void! query_user(char[] username) {
    char[] sql = sprintf("SELECT * FROM users WHERE name = '%s'", username);
    db.execute(sql);
}

// CORRECT - parameterized query
fn void! query_user(char[] username) {
    db.execute("SELECT * FROM users WHERE name = ?", username);
}
```

## S9: Use Constant-Time Comparison for Secrets

```c3
fn bool secure_compare(char[] a, char[] b) {
    if (a.len != b.len) return false;

    char result = 0;
    for (usz i = 0; i < a.len; i++) {
        result |= a[i] ^ b[i];
    }
    return result == 0;
}
```
