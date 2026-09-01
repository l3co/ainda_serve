# Python Security Guidance

## General Posture

Security is not a post-processing step. Review every change against this checklist before declaring a task complete. Flag any concern found — even if the task did not explicitly mention security.

## Input Validation

- Validate all external input at the system boundary (API endpoints, CLI args, message consumers, file uploads).
- Use Pydantic models or dataclasses with validation for structured input.
- Define maximum sizes for strings and collections. Reject inputs that exceed them.
- Never trust input from headers, query parameters, or request bodies without validation.

## SQL Injection

Always use parameterized queries — never interpolate user input into SQL strings:

```python
# Incorrect — SQL injection risk:
cursor.execute(f"SELECT * FROM users WHERE email = '{email}'")

# Correct — parameterized:
cursor.execute("SELECT * FROM users WHERE email = %s", (email,))

# Correct — SQLAlchemy ORM:
session.query(User).filter(User.email == email).first()

# Correct — SQLAlchemy core with text():
from sqlalchemy import text
session.execute(text("SELECT * FROM users WHERE email = :email"), {"email": email})
```

Never use string formatting or concatenation to build SQL queries.

## Command Injection

Avoid `subprocess` with `shell=True` when any part of the command comes from user input:

```python
# Incorrect — shell injection risk:
subprocess.run(f"grep {user_input} /var/log/app.log", shell=True)

# Correct — no shell; arguments as a list:
subprocess.run(["grep", "--", user_input, "/var/log/app.log"], shell=False)
```

Prefer `subprocess.run` with a list of arguments over `os.system`.

## Pickle Deserialization

Never deserialize untrusted data with `pickle`, `marshal`, or `shelve`:

```python
# Dangerous — arbitrary code execution:
obj = pickle.loads(untrusted_bytes)

# Safe alternatives for data interchange:
import json
data = json.loads(untrusted_string)  # validates structure explicitly
```

Use `json`, `msgpack`, or explicit schema validation (Pydantic) for untrusted data.

## Path Traversal

When using user-provided file names or paths, validate them against an allowed base directory:

```python
import os

BASE_DIR = "/var/uploads"

def safe_path(filename: str) -> str:
    target = os.path.realpath(os.path.join(BASE_DIR, filename))
    if not target.startswith(os.path.realpath(BASE_DIR) + os.sep):
        raise ValueError("path traversal detected")
    return target
```

## SSRF (Server-Side Request Forgery)

- Never make HTTP requests to URLs provided directly by users without validation.
- Validate that outgoing URLs match an allowlist of expected schemes and hostnames.
- Do not follow redirects to internal network addresses.

## Secrets Management

- Never store secrets (passwords, API keys, tokens) in source code or committed configuration files.
- Use environment variables loaded via `python-decouple`, `pydantic-settings` (`BaseSettings`), or `os.environ`.
- Use `.env` files only for local development — ensure `.env` is in `.gitignore`.
- Do not log secret values, even at `DEBUG` level.

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str

    class Config:
        env_file = ".env"
```

## Django and Flask Specific

- Django CSRF middleware is enabled by default — do not disable it for stateful views.
- Use `{% csrf_token %}` in all Django forms.
- Set `SECURE_SSL_REDIRECT`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE` in production.
- Never use `mark_safe()` with user-controlled content.
- Flask: use `flask-wtf` for CSRF protection; set `SECRET_KEY` from an environment variable.

## FastAPI Specific

- Use `Depends` with security utilities (`OAuth2PasswordBearer`, API key headers) for authentication.
- Validate all path parameters, query parameters, and body fields with Pydantic models.
- Set appropriate CORS origins (`allow_origins`) — never use `["*"]` in production with credentials.

## Dependency Security

- Run `pip audit` or `safety check` in CI to detect known vulnerabilities.
- Pin versions in `requirements.txt` for deployed applications.
- Separate development dependencies from production ones.
- Review changelogs and CVEs before updating dependencies.

## Error Exposure

- Do not return stack traces, internal error messages, or file paths to API clients.
- Log the full error internally; return a generic message externally:

```python
# FastAPI example:
@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.error("unexpected error", exc_info=exc)
    return JSONResponse(status_code=500, content={"detail": "internal server error"})
```

## Template Injection

- When using Jinja2 or Django templates, never render user-controlled strings as templates.
- Use `Environment(autoescape=True)` in Jinja2 for HTML contexts.
- Escape user content before embedding it in HTML responses.

## Security Review Checklist

Before completing any task involving HTTP endpoints, database access, file handling, or user input:

- [ ] All database queries use parameterized inputs or ORM query builders
- [ ] No user input is interpolated into SQL strings
- [ ] `subprocess` calls do not use `shell=True` with user-provided arguments
- [ ] No `pickle.loads` on untrusted data
- [ ] File paths from user input are validated against allowed directories
- [ ] No secrets in source code or committed configuration files
- [ ] Error responses do not expose stack traces or internal details
- [ ] CSRF protection is enabled for stateful web applications
- [ ] `pip audit` or `safety` reports no critical vulnerabilities in new/updated dependencies
- [ ] No `mark_safe()` or equivalent with user-controlled content
