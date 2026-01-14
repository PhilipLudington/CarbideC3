# /carbide-review

Perform a comprehensive code review against CarbideC3 standards.

## Instructions

Review the code for compliance with CarbideC3 standards. Check each category:

### 1. Naming (N1-N9)
- [ ] Types are PascalCase
- [ ] Functions are snake_case
- [ ] Variables are snake_case
- [ ] Constants are UPPER_SNAKE_CASE
- [ ] Faults are UPPER_SNAKE_CASE
- [ ] Names are descriptive, not abbreviated

### 2. Memory Management (M1-M6)
- [ ] Functions accept allocator parameters
- [ ] `defer` immediately follows resource acquisition
- [ ] Error paths use `defer if (@catch)`
- [ ] Ownership is documented
- [ ] Structs have init/deinit lifecycle

### 3. Error Handling (E1-E7)
- [ ] Faults are domain-specific
- [ ] Optional types used for fallible functions
- [ ] Errors propagated with `!` where appropriate
- [ ] Errors handled with `if (catch)` where needed
- [ ] No `!!` on user input

### 4. API Design (A1-A8)
- [ ] Functions accept slices, not ptr+len
- [ ] Optional types for nullable returns
- [ ] Structs returned for multiple values
- [ ] Config structs use defaults
- [ ] Ownership documented in signatures

### 5. Contracts (C1-C7)
- [ ] Preconditions use `@require`
- [ ] Postconditions use `@ensure`
- [ ] Contracts are checkable expressions
- [ ] Contract rationale documented

### 6. Security (S1-S9)
- [ ] External input validated
- [ ] Buffer sizes limited
- [ ] Slices used over raw pointers
- [ ] Integer overflow checked
- [ ] Sensitive data cleared

## Output Format

Provide findings as:
```
## Review Summary

**Overall**: PASS/NEEDS_WORK/FAIL

### Issues Found

1. **[Category]** File:Line - Description
   - Current: `code`
   - Suggested: `code`

### Recommendations

- Priority fixes
- Style improvements
```
