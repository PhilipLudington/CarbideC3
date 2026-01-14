/**
 * Hello Library Module
 *
 * Example library demonstrating CarbideC3 patterns.
 */
module hello;

// Fault definitions (E1: Specific faults)
faultdef MATH_ERROR {
    DIVISION_BY_ZERO,
    OVERFLOW,
}

// Safe division with optional return (E2)
<*
 * Performs safe integer division.
 *
 * @param a : "Dividend"
 * @param b : "Divisor"
 * @return "Quotient or DIVISION_BY_ZERO fault"
 * @require b != 0 || return == DIVISION_BY_ZERO? : "Zero divisor returns fault"
 *>
fn int? safe_divide(int a, int b) {
    if (b == 0) return DIVISION_BY_ZERO?;
    return a / b;
}

// Counter struct demonstrating lifecycle pattern (M6)
struct Counter {
    int count;
}

<* Initialize a counter with starting value. *>
fn Counter Counter.init(int start) {
    return { .count = start };
}

<* Clean up counter resources (none in this case). *>
fn void Counter.deinit(&self) {
    // No resources to free, but pattern is established
}

<* Increment the counter. *>
fn void Counter.increment(&self) {
    self.count++;
}

<* Get current counter value. *>
fn int Counter.value(&self) {
    return self.count;
}

// Boolean query pattern (N7)
fn bool Counter.is_zero(&self) {
    return self.count == 0;
}
