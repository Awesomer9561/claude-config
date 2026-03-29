# Code Review Checklist

Apply these checks to every changed file. Severity classification follows `~/.claude/code-reviewer/config.json`.

---

## 1. Security (BLOCKING)

- [ ] **Hardcoded secrets**: API keys, passwords, tokens, connection strings in source code
- [ ] **SQL injection**: Raw string concatenation in queries (use parameterized queries/ORM)
- [ ] **XSS**: Unescaped user input rendered in HTML/templates
- [ ] **Command injection**: User input passed to shell/exec/process calls
- [ ] **Path traversal**: User input used in file paths without sanitization
- [ ] **Auth bypass**: Missing authentication/authorization checks on endpoints
- [ ] **Insecure deserialization**: Untrusted data deserialized without validation
- [ ] **Sensitive data exposure**: PII, tokens, or secrets logged or returned in responses
- [ ] **SSRF**: User-controlled URLs fetched server-side without allowlist

## 2. Data Integrity (BLOCKING)

- [ ] **Data loss risk**: DELETE/DROP/TRUNCATE without safeguards or confirmation
- [ ] **Missing transactions**: Multi-step DB operations without transaction wrapping
- [ ] **Race conditions**: Concurrent access to shared state without locking
- [ ] **Missing validation**: User input accepted without boundary validation
- [ ] **Null safety**: Potential null reference exceptions on critical paths

## 3. Logic Errors (BLOCKING)

- [ ] **Off-by-one errors**: Loop bounds, array indexing, pagination
- [ ] **Inverted conditions**: Boolean logic that does the opposite of intent
- [ ] **Missing error paths**: Functions that can fail but don't handle failure
- [ ] **Breaking API contracts**: Changes that break existing callers/consumers
- [ ] **Resource leaks**: Opened connections/streams/handles not closed/disposed

## 4. Performance (WARNING)

- [ ] **N+1 queries**: Loop with individual DB calls instead of batch/join
- [ ] **Missing pagination**: Unbounded queries that return all rows
- [ ] **Unnecessary allocations**: Objects created in hot loops
- [ ] **Missing indexes**: New queries on columns without indexes
- [ ] **Blocking I/O**: Sync I/O on async paths
- [ ] **Missing caching**: Repeated expensive computations without cache

## 5. Error Handling (WARNING)

- [ ] **Swallowed exceptions**: Empty catch blocks or catch-and-ignore
- [ ] **Generic catches**: Catching base Exception instead of specific types
- [ ] **Missing error context**: Exceptions re-thrown without context/message
- [ ] **Unhandled edge cases**: No handling for empty collections, null returns, timeouts

## 6. Testing (WARNING)

- [ ] **New logic without tests**: Significant new business logic with no test coverage
- [ ] **Broken test patterns**: Tests that don't actually assert anything meaningful
- [ ] **Test-only code in production**: Test utilities or mocks in production code paths

## 7. Code Structure (NOTE)

- [ ] **Function too long**: Functions exceeding project's convention (typically 50-80 lines)
- [ ] **Deep nesting**: More than 3-4 levels of nesting
- [ ] **Dead code**: Unreachable code, unused imports, commented-out blocks
- [ ] **Duplication**: Repeated code that should be extracted to a shared function
- [ ] **Naming**: Variables/functions that don't describe their purpose

## 8. Project Conventions (from profile)

- [ ] **Naming conventions**: Does the code follow the project's naming style?
- [ ] **Architecture patterns**: Does the code respect the project's layering/structure?
- [ ] **Import/dependency style**: Are imports organized per project convention?
- [ ] **Error handling style**: Does error handling match the project's established pattern?
- [ ] **Test organization**: Are tests placed and named per project convention?

---

## How to Apply

1. For each changed file, walk through sections 1-7
2. For section 8, reference the project profile
3. If a check fails, create a finding with: file, line number, category, description, suggested fix
4. Classify the finding using the severity rules in config.json
5. If uncertain about severity, default to WARNING (not BLOCKING)
