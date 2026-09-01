# Elixir-Specific Guardrails

These guardrails apply to all agents working on Elixir codebases. They extend — not replace — the shared guardrails in `../shared/guardrails.md`. In any conflict, the shared guardrails take precedence unless noted here.

---

## Error Handling

MUST use `{:ok, value}` and `{:error, reason}` for all functions that can fail.

MUST NOT return `nil` as a signal for absence or failure — use `{:error, :not_found}` or `{:ok, nil}` when nil is a valid successful result.

MUST NOT use `raise` / `throw` for domain-level errors — reserve them for unrecoverable programmer errors or OTP signals.

MUST NOT swallow errors with a bare `_` in a `case` or `with` else clause without logging or re-raising.

MUST include an `else` clause in `with` expressions when different steps can produce different error shapes.

MUST propagate errors to callers rather than logging and returning `:ok` when the error is meaningful.

---

## Atoms

MUST NOT create atoms from untrusted user input using `String.to_atom/1`.

MUST NOT use `:"#{user_input}"` interpolation to create atoms dynamically from external data.

SHOULD use `String.to_existing_atom/1` with an explicit allowlist, or use a validated enum, when parsing user-supplied role/status values.

---

## Processes and OTP

MUST NOT spawn a process when a function call would suffice.

MUST NOT use a GenServer solely to hold state that could be threaded as function arguments.

MUST document the termination path of every process: what stops it, under what conditions, and who is responsible.

MUST register processes (`:name`) only when global lookup is required — prefer passing the pid or using a process registry.

MUST NOT use `Process.sleep/1` in production code for coordination — use `receive`, `Task.await`, or timeouts.

MUST add spawned Tasks and GenServers to a Supervisor when their failure matters to the application.

MUST configure Supervisors with an appropriate restart strategy and `max_restarts`/`max_seconds` to prevent infinite restart loops.

MUST NOT catch exits with `Process.flag(:trap_exit, true)` in application processes without a documented reason.

---

## Ecto and Database

MUST use Ecto parameterized queries — never interpolate user data into raw SQL or `fragment/1` strings.

MUST run all external inputs through a changeset before inserting or updating database records.

MUST NOT use `Repo.get!/1` in contexts where the record may legitimately not exist — use `Repo.get/1` and handle `nil` explicitly.

MUST NOT use `Repo.update_all/2` or `Repo.delete_all/2` with user-controlled filter conditions without explicit validation.

MUST run migrations with an explicit rollback strategy for destructive changes.

MUST NOT modify already-applied migrations — create a new migration.

SHOULD use `Ecto.Multi` for multi-step database operations that must be atomic.

MUST NOT keep a database transaction open while making external HTTP calls or sleeping.

---

## Phoenix and Web

MUST NOT remove `Plug.CSRFProtection` from the browser pipeline.

MUST NOT use `raw/1` in HEEx templates with user-provided content that has not been sanitized.

MUST NOT trust `user_id`, `role`, or ownership claims from the request body — use `conn.assigns.current_user` set by authentication plugs.

MUST validate and restrict file upload size, type, and filename before processing.

MUST NOT expose Phoenix debug pages (`Plug.Debugger`) in production.

MUST NOT render internal Elixir errors or stack traces in API error responses.

---

## Secrets and Configuration

MUST NOT place secrets in `config/config.exs`, `config/dev.exs`, or any compile-time config file.

MUST use `config/runtime.exs` with `System.fetch_env!/1` for all environment-specific secrets.

MUST NOT commit `.env` files or files containing production credentials.

MUST NOT log secret values, even during debugging.

---

## Testing

MUST NOT use `Process.sleep/1` in tests — use `assert_receive`, `Task.await`, or process monitoring.

MUST NOT use globally named processes in `async: true` tests (name conflicts between concurrent test processes).

MUST NOT test private functions directly — test through the public interface.

MUST NOT alter changeset validation in tests to avoid failures — test the validation itself.

MUST use the SQL Sandbox for database tests and confirm `async: true` is safe.

SHOULD use `Mox` for mocking external dependencies behind a behaviour — not for mocking the module under test.

---

## Logging and Observability

MUST NOT log passwords, tokens, or personal identifiers.

MUST NOT use `IO.puts` or `IO.inspect` for operational logging — use `Logger`.

MUST NOT log full request parameters when they may contain sensitive fields.

SHOULD attach correlation identifiers using `Logger.metadata/1` at the boundary of each request or job.

SHOULD define `:telemetry` events for measurable operations (HTTP requests, DB queries, job processing).

MUST NOT include secrets or PII in telemetry event metadata.

---

## Dependencies

MUST NOT add a library that duplicates standard OTP functionality without justification.

MUST review all dependencies using `mix deps.audit` for known vulnerabilities.

MUST NOT use abandoned packages for auth, cryptography, or parsing of untrusted input.

SHOULD pin minor versions for security-critical dependencies and review diffs when updating.

---

## Code Style Guardrails

MUST NOT use `IO.inspect` in committed code — use `Logger.debug/2` with a tag.

MUST NOT use `_ = something` to silence unused variable warnings without a comment explaining why the result is discarded.

MUST NOT write `defp` functions that are longer than can be understood in one reading — extract to named functions.

MUST NOT use `send/2` and `receive/1` in application code when a GenServer `call` or `cast` is appropriate.

MUST NOT suppress Dialyzer warnings without a comment explaining the false-positive or the accepted risk.
