/**
 * CarbideC3 Hello World Example
 *
 * Demonstrates basic CarbideC3 patterns:
 * - Module declaration
 * - Error handling with optionals
 * - Resource cleanup with defer
 * - Contracts
 */
module main;

import std::io;
import hello;

fn void main() {
    // Basic greeting
    io::printn("Hello, CarbideC3!");

    // Demonstrate error handling
    int? result = hello::safe_divide(10, 2);
    if (try value = result) {
        io::printfn("10 / 2 = %d", value);
    }

    // Demonstrate error case
    int? error_result = hello::safe_divide(10, 0);
    if (catch err = error_result) {
        io::printfn("Division failed: %s", err.nameof);
    }

    // Demonstrate struct lifecycle
    hello::Counter counter = hello::Counter.init(0);
    defer counter.deinit();

    counter.increment();
    counter.increment();
    io::printfn("Counter value: %d", counter.value());
}
