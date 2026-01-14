# /carbide-safety

Perform a security-focused code review.

## Instructions

Analyze the code for security vulnerabilities. Check for:

### Input Validation
- [ ] All external input validated at boundaries
- [ ] Size limits enforced on buffers and collections
- [ ] Integer overflow checked on arithmetic
- [ ] Path traversal prevented on file operations

### Memory Safety
- [ ] Slices used instead of raw pointers
- [ ] Bounds checking via foreach/slices
- [ ] No use-after-free patterns
- [ ] Sensitive data zeroed before free

### Injection Prevention
- [ ] No format string vulnerabilities
- [ ] SQL queries parameterized
- [ ] Command injection prevented
- [ ] Path injection prevented

### Common Vulnerabilities (OWASP/CWE)
- [ ] CWE-119: Buffer overflow
- [ ] CWE-125: Out-of-bounds read
- [ ] CWE-190: Integer overflow
- [ ] CWE-22: Path traversal
- [ ] CWE-78: Command injection
- [ ] CWE-89: SQL injection
- [ ] CWE-134: Format string

## Output Format

```
## Security Review

**Risk Level**: LOW/MEDIUM/HIGH/CRITICAL

### Vulnerabilities Found

1. **[CWE-XXX]** File:Line - Description
   - Impact: What could happen
   - Fix: How to resolve

### Recommendations

- Immediate fixes required
- Defensive improvements
```
