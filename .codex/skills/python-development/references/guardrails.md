# Python-Specific Guardrails

These guardrails apply to all agents working on Python codebases. They extend — not replace — the shared guardrails in `../shared/guardrails.md`. In any conflict, the shared guardrails take precedence unless noted here.

---

## Exception Handling

MUST NOT use bare `except:` — always name the exception or catch `Exception` explicitly.

MUST NOT swallow exceptions with `except Exception: pass`.

SHOULD use `logger.exception(...)` or re-raise when catching broad exceptions.

MUST include the original exception when raising a new one: `raise AppError("context") from e`.

MUST NOT use exceptions for normal control flow when a conditional check would suffice.

SHOULD define custom exceptions at the appropriate domain layer.

---

## Type Hints

MUST use type hints for all public function signatures.

MUST NOT use `Any` as a return type for functions whose output type can be specified.

MUST use `X | None` (Python 3.10+) or `Optional[X]` for optional values — never return `None` without annotating it.

SHOULD use `from __future__ import annotations` for forward references.

MUST NOT use mutable default arguments (`def f(items: list = [])`) — use `None` with a runtime check.

SHOULD use `TypeAlias` for complex type synonyms.

---

## Classes and Functions

MUST prefer functions over classes for stateless logic.

MUST NOT create classes with only static or class methods when a module with functions would suffice.

MUST NOT use `__init__` to perform I/O, network calls, or database access.

MUST NOT create inheritance hierarchies more than two levels deep unless modeling a true generalization.

SHOULD use `@dataclass(frozen=True)` for value objects.

SHOULD use `Protocol` for structural interfaces instead of `ABC` when no shared behavior is needed.

---

## Imports and Modules

MUST NOT use wildcard imports (`from module import *`) in non-`__init__` files.

MUST NOT use circular imports.

SHOULD organize imports following `isort` conventions: standard library, then third-party, then local.

MUST NOT execute I/O, network, or database connections at import time.

MUST NOT use `importlib.import_module` or `__import__` on user-provided input.

---

## Testing

MUST use `pytest` — not `unittest` unless the project already uses it.

MUST NOT use `assert` outside tests — prefer explicit checks with meaningful exceptions.

MUST write fixtures at the appropriate `conftest.py` level — project-scoped fixtures belong in the root or top-level `conftest.py`.

MUST NOT use `monkeypatch` in integration tests that should exercise real behavior.

MUST NOT create test modules without the `test_` prefix (will be silently skipped).

SHOULD use `pytest.mark.parametrize` for multiple input cases.

MUST test error paths, not only happy paths.

MUST NOT use `time.sleep` in tests — use controlled fakes or mock clocks.

---

## Async

MUST use `async def` / `await` consistently — do not mix sync and async in the same call chain without care.

MUST NOT call `asyncio.run()` inside an already-running event loop.

MUST NOT use `asyncio.sleep(0)` as a yield point without a documented reason.

SHOULD use `asyncio.gather` for concurrent tasks with known completion points.

MUST propagate cancellation — do not swallow `asyncio.CancelledError`.

MUST NOT use `threading` to work around async when the framework is async-first.

---

## Security (Python-Specific)

MUST use parameterized queries (`cursor.execute("SELECT ... WHERE id = %s", (id,))`) — never f-strings in SQL.

MUST NOT use `subprocess.shell=True` with user-provided input — use a fixed argument list.

MUST NOT use `eval()` or `exec()` on user-controlled input.

MUST NOT use `pickle.loads()` on untrusted data.

MUST validate and restrict file paths before reading or writing to prevent path traversal.

MUST NOT use `md5` or `sha1` from `hashlib` for security-critical operations.

MUST use `secrets` module for cryptographically secure random values — not `random`.

MUST NOT log request parameters or bodies that may contain credentials or PII.

---

## Observability

SHOULD use `structlog` for structured logging when the project already uses it.

MUST NOT use `print()` for operational logging.

SHOULD propagate context variables using `contextvars.ContextVar` across async boundaries.

MUST include correlation identifiers (request ID, trace ID) in log entries for distributed flows.

MUST NOT log sensitive data (passwords, tokens, personal identifiers, PII).

SHOULD use `logger.warning("event: %s", value)` — lazy formatting, not f-strings in log calls.

---

## Dependencies and Environment

MUST NOT add a dependency solvable with the standard library.

MUST pin versions in `requirements.txt` or `pyproject.toml` — no bare `package>=0.0.0`.

MUST NOT use `pip install` in code — document installation in project setup instructions.

MUST NOT access environment variables directly in domain logic — centralize configuration.

MUST use `.env` files with a loader library (e.g., `python-dotenv`) and MUST NOT commit `.env` to version control.

---

## Code Style Guardrails

MUST NOT use string multiplication for formatting (`"-" * 80`) in production output.

MUST NOT use `isinstance()` for flow control when `Protocol`s or overloading would be more appropriate.

MUST NOT compare to `True` or `False` with `==` — use truthiness checks.

MUST NOT mutate a list or dict while iterating over it.

SHOULD use list comprehensions instead of `map` + `lambda` for simple transformations.

MUST NOT use `assert` for input validation in non-test code — assertions are stripped with `-O`.
