# Code Review Checklist

Apply these checks to every changed file. Severity classification follows `~/.claude/code-reviewer/config.json`.
Rate each dimension: ✅ Clean | ⚠️ Issues | 🚨 Critical

---

## 1. Security

- [ ] **Hardcoded secrets**: API keys, passwords, tokens, connection strings in source code — BLOCKING
- [ ] **SQL injection**: Raw string concatenation in queries (use parameterized queries/ORM) — BLOCKING
- [ ] **XSS**: Unescaped user input rendered in HTML/templates — BLOCKING
- [ ] **CSRF**: Missing CSRF tokens on state-changing endpoints — BLOCKING
- [ ] **Command injection**: User input passed to shell/exec/process calls — BLOCKING
- [ ] **Path traversal**: User input used in file paths without sanitization — BLOCKING
- [ ] **Auth bypass**: Missing authentication/authorization checks on endpoints — BLOCKING
- [ ] **Insecure deserialization**: Untrusted data deserialized without validation — BLOCKING
- [ ] **Sensitive data exposure**: PII, tokens, or secrets logged or returned in responses — BLOCKING
- [ ] **SSRF**: User-controlled URLs fetched server-side without allowlist — BLOCKING

## 2. Performance

- [ ] **N+1 queries**: Loop with individual DB calls instead of batch/join — WARNING
- [ ] **Unbounded queries**: Missing pagination; queries that return all rows — WARNING
- [ ] **Algorithmic complexity**: O(n²) or worse in hot paths — WARNING
- [ ] **Unnecessary memory allocations**: Objects created in tight loops — WARNING
- [ ] **Missing indexes**: New queries on columns without indexes — WARNING
- [ ] **Blocking I/O**: Sync I/O on async paths — WARNING
- [ ] **Resource leaks**: Opened connections/streams/handles not closed/disposed — BLOCKING
- [ ] **Missing caching**: Repeated expensive computations without cache — NOTE

## 3. Correctness

- [ ] **Edge cases**: Empty input, null, integer overflow, empty collections — BLOCKING
- [ ] **Race conditions**: Concurrent access to shared state without locking — BLOCKING
- [ ] **Off-by-one errors**: Loop bounds, array indexing, pagination — BLOCKING
- [ ] **Inverted conditions**: Boolean logic that does the opposite of intent — BLOCKING
- [ ] **Missing error paths**: Functions that can fail but don't handle failure — BLOCKING
- [ ] **Type safety**: Unsafe casts, unchecked type assertions — BLOCKING
- [ ] **Breaking API contracts**: Changes that break existing callers/consumers — BLOCKING
- [ ] **Data loss risk**: DELETE/DROP/TRUNCATE without safeguards — BLOCKING
- [ ] **Missing transactions**: Multi-step DB operations without transaction wrapping — BLOCKING
- [ ] **Swallowed exceptions**: Empty catch blocks or catch-and-ignore — WARNING
- [ ] **Generic catches**: Catching base Exception instead of specific types — WARNING
- [ ] **Missing error context**: Exceptions re-thrown without context/message — WARNING
- [ ] **Unhandled edge cases**: No handling for empty collections, null returns, timeouts — WARNING
- [ ] **Unit tests**: New logic without tests is BLOCKING for major changes; run `dotnet test *.UnitTests` — BLOCKING/WARNING
- [ ] **Broken test patterns**: Tests that don't actually assert anything meaningful — WARNING

## 4. Maintainability

- [ ] **Naming clarity**: Variables/functions that don't describe their purpose — NOTE
- [ ] **Single responsibility**: Functions doing too many things or exceeding ~80 lines — NOTE
- [ ] **Deep nesting**: More than 3-4 levels of nesting — NOTE
- [ ] **Duplication**: Repeated code that should be extracted to a shared function — NOTE
- [ ] **Dead code**: Unreachable code, unused imports, commented-out blocks — NOTE
- [ ] **Documentation**: Non-obvious logic without explanation — NOTE
- [ ] **Naming conventions**: Does the code follow the project's naming style? — NOTE
- [ ] **Architecture patterns**: Does the code respect the project's layering/structure? — NOTE
- [ ] **Import/dependency style**: Are imports organized per project convention? — NOTE
- [ ] **Error handling style**: Does error handling match the project's established pattern? — NOTE
- [ ] **Test organization**: Are tests placed and named per project convention? — NOTE

---

## How to Apply

1. For each changed file, walk through all four dimensions
2. For Maintainability section 4, also reference the project profile for project-specific conventions
3. If a check fails, create a finding with: file, line number, dimension, severity, description, suggested fix
4. Rate each dimension at the end: ✅ Clean | ⚠️ Issues | 🚨 Critical
5. If uncertain about severity, default to WARNING (not BLOCKING)
