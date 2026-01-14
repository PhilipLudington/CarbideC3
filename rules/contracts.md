# Contract Rules

## C1: Use @require for Preconditions

Validate inputs with `@require`.

```c3
<*
 * @param count : "Items to allocate"
 * @require count > 0 : "Count must be positive"
 * @require count <= MAX_ITEMS : "Count exceeds limit"
 *>
fn Item[]! allocate_items(usz count) {
    // Contract checked before function body executes
}
```

## C2: Use @ensure for Postconditions

Validate outputs with `@ensure`.

```c3
<*
 * @param value : "Input value"
 * @return "Absolute value"
 * @ensure return >= 0 : "Result is non-negative"
 *>
fn int abs(int value) {
    return value < 0 ? -value : value;
}
```

## C3: Contracts Must Be Checkable

Contracts must express verifiable conditions.

```c3
// WRONG - uncheckable
<* @require "buffer is valid" *>

// CORRECT - checkable
<* @require buffer.len > 0 *>
<* @require buffer.len <= MAX_SIZE *>
```

## C4: Document Contract Rationale

Explain why the contract exists.

```c3
<*
 * @require port != 0 : "Port 0 is reserved for OS assignment"
 * @require port < 65536 : "Port must fit in 16 bits"
 *>
fn void! bind(uint port) { }
```

## C5: Combine Contracts with Types

Use contracts to express relationships types can't capture.

```c3
<*
 * @require start <= end : "Range must be valid"
 * @require end <= buffer.len : "Range must be within buffer"
 *>
fn char[] slice(char[] buffer, usz start, usz end) {
    return buffer[start..end];
}
```

## C6: Contract Inheritance

Subtype contracts should be compatible with parent.

```c3
interface Comparable {
    <* @ensure (return == 0) == (a == b) *>
    fn int compare(Self a, Self b);
}
```

## C7: Debug vs Release Behavior

Contracts are checked in debug builds. Write code that's correct even without them.

```c3
<* @require index < self.len *>
fn T get(&self, usz index) {
    // Still safe even if contract disabled in release:
    if (index >= self.len) return T.default;
    return self.items[index];
}
```
