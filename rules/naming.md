# Naming Conventions

## N1: Type Names are PascalCase

All user-defined types start with uppercase (C3 enforces this).

```c3
struct HttpClient { }
struct ParseResult { }
enum Status { PENDING, ACTIVE }
typedef UserId = uint;
```

## N2: Functions are snake_case

```c3
fn void read_file() { }
fn int parse_header() { }
fn bool is_valid() { }
```

## N3: Variables are snake_case

```c3
int buffer_size = 1024;
bool is_connected = false;
char[] response_data;
```

## N4: Constants are UPPER_SNAKE_CASE

```c3
const int MAX_BUFFER_SIZE = 8192;
const String DEFAULT_HOST = "localhost";
```

## N5: Faults are UPPER_SNAKE_CASE

```c3
faultdef PARSE_ERROR, IO_ERROR, NOT_FOUND;
```

## N6: Modules are snake_case

```c3
module http_client;
module json_parser;
module string_utils;
```

## N7: Method Naming Patterns

```c3
// Initialization/deinitialization
fn Type Type.init() { }
fn void Type.deinit(&self) { }

// Getters - no prefix
fn String Type.name(&self) { }
fn int Type.count(&self) { }

// Boolean queries - is_/has_ prefix
fn bool Type.is_ready(&self) { }
fn bool Type.has_value(&self) { }

// Setters - set_ prefix
fn void Type.set_name(&self, String n) { }

// Actions - verb first
fn void! Type.connect(&self) { }
fn usz! Type.read(&self, char[] buf) { }
fn void! Type.write(&self, char[] data) { }

// Conversions
fn char[] Type.to_slice(&self) { }
fn Type! Type.from_bytes(char[] b) { }
```

## N8: Avoid Abbreviations

```c3
// WRONG
int buf_sz;
char[] resp;
fn void proc_msg() { }

// CORRECT
int buffer_size;
char[] response;
fn void process_message() { }
```

## N9: Boolean Variables

Boolean variables should read as assertions.

```c3
// WRONG
bool connected;
bool error;
bool valid;

// CORRECT
bool is_connected;
bool has_error;
bool is_valid;
```
