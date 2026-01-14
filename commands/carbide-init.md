# /carbide-init

Initialize a new CarbideC3 project.

## Instructions

Create a new C3 project with CarbideC3 standards. Generate:

### Project Structure

```
project_name/
├── project.json
├── src/
│   ├── main.c3
│   └── lib.c3
├── test/
│   └── lib_test.c3
└── .claude/
    └── settings.json
```

### project.json

```json
{
  "name": "project_name",
  "version": "0.1.0",
  "authors": ["Author Name"],
  "sources": ["src/**/*.c3"],
  "dependencies": {}
}
```

### src/main.c3

```c3
module main;

import std::io;

fn void main() {
    io::printn("Hello, CarbideC3!");
}
```

### src/lib.c3

```c3
<*
 * Project Library
 *
 * Main library module for project_name.
 *>
module lib;

// Public API

<* Example function demonstrating CarbideC3 patterns. *>
fn int! example_function(int value) {
    if (value < 0) return INVALID_ARGUMENT?;
    return value * 2;
}

faultdef INVALID_ARGUMENT;
```

### test/lib_test.c3

```c3
module lib_test;

import lib;
import std::testing;

fn void! test_example_function() @test {
    int result = lib::example_function(5)!;
    testing::assert_eq(result, 10);
}

fn void! test_example_function_error() @test {
    int? result = lib::example_function(-1);
    testing::assert(@catch(result) == lib::INVALID_ARGUMENT);
}
```

### .claude/settings.json

```json
{
  "rules": ["memory", "errors", "naming", "api-design", "contracts", "security"]
}
```

## Prompt User

Ask for:
1. Project name
2. Author name
3. Brief description
