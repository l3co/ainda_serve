# Ruby/Rails Security Reference

These extend the shared security guardrails with Ruby/Rails-specific
mechanics. All of the shared guardrails' "Security Protection" and
"Authentication and Authorization" sections apply in full.

## SQL injection

Rails' query interface parameterizes by default — use it, never build SQL
by interpolating untrusted input:

```ruby
# Vulnerable
User.where("email = '#{params[:email]}'")

# Safe
User.where(email: params[:email])
User.where("email = ?", params[:email])
```

`sanitize_sql_array` is the escape hatch when a query genuinely needs to
be composed dynamically — never raw string interpolation.

## Mass assignment

Strong parameters, always. Never pass raw `params` to `create`/`update`/
`new`:

```ruby
# Vulnerable — a client could set admin: true
User.create(params[:user])

# Safe
def user_params
  params.require(:user).permit(:name, :email)
end
```

## Cross-site scripting (XSS)

ERB auto-escapes by default. Never bypass it for untrusted input:

```erb
<%# Vulnerable if body contains user input %>
<%= raw @review.body %>
<%= @review.body.html_safe %>

<%# Safe %>
<%= @review.body %>
<%= sanitize(@review.body, tags: %w[b i em strong]) %>  # only if HTML is genuinely expected
```

`html_safe`/`raw` on anything derived from user input is a red flag —
treat every occurrence as something to justify explicitly, not a routine
call.

## Cross-site request forgery (CSRF)

Never disable `protect_from_forgery`/`allow_forgery_protection` to make a
controller "easier" to call from a test or a script — fix the test/client
to carry the CSRF token instead. API controllers authenticated by bearer
token (stateless, no session cookie) are the one legitimate case for
skipping CSRF protection on that specific controller — document why when
doing so.

## Authentication

- Passwords: `has_secure_password` (bcrypt under the hood). Never
  implement custom password hashing.
- Never compare secrets/tokens with `==` where a timing attack is a real
  concern (API tokens, webhook signatures) — use
  `ActiveSupport::SecurityUtils.secure_compare`.
- Password reset / email confirmation tokens: Rails 8's
  `generates_token_for` (signed, expiring, purpose-scoped) rather than a
  hand-rolled random token stored in a column.

## Authorization

- Validate ownership/permission on the server for every mutating action —
  never rely on a client-hidden button or disabled field as the actual
  control.
- Never trust a client-supplied role or ID as the source of truth for
  "can this user do this" — look it up server-side
  (`current_user.admin?`, not `params[:role] == "admin"`).
- Returning a resource because its ID is known and guessable (sequential
  IDs, or a UUID leaked elsewhere) without an ownership check is an
  authorization bug, not a "who would guess that" acceptable risk.

## Insecure deserialization

- Never `Marshal.load` untrusted input — it can execute arbitrary code.
- Use `YAML.safe_load` (or `Psych.safe_load`), never bare `YAML.load`, on
  any YAML that could originate outside the codebase.
- Treat any cache/session backend storing serialized Ruby objects as a
  place untrusted input must never reach.

## Command and code injection

- Never pass untrusted input to `system`, backticks, `` `cmd` ``,
  `Kernel#eval`, or `send`/`public_send` with a method name derived from
  user input without an explicit allowlist.
- `Open3.capture3` with an argument array (not an interpolated string) is
  the safe way to shell out when genuinely necessary.

## Server-side request forgery (SSRF)

Any feature that fetches a URL supplied (even indirectly) by a user — an
avatar-from-URL field, a webhook target, a "fetch preview" feature — must
validate/allowlist the target before requesting it. Do not let the app
become an open proxy for internal network addresses.

## Open redirects

Never `redirect_to params[:url]` or similar without validating the target
is an internal, expected path — an attacker-controlled redirect target is
a phishing vector.

## Secrets

- Rails credentials (`Rails.application.credentials`, encrypted with
  `RAILS_MASTER_KEY`) or environment variables — never a plaintext value
  in a committed `config/*.yml`.
- `RAILS_MASTER_KEY`/`config/master.key` is never committed; it's supplied
  via the deploy platform's environment (matching the shared guardrail on
  data and secrets).
- Never log a request's raw params/headers when a route handles
  credentials, tokens, or payment data.

## Background jobs

- A job's `perform` arguments are serialized and can be inspected/retried
  later — never pass a raw password, token, or full credit-card number as
  a job argument; pass an ID and re-fetch, or pass an already-redacted
  value.
- Jobs must be idempotent and safe to retry — a job that isn't safe to run
  twice (e.g., "charge this payment") needs an explicit idempotency key,
  not an assumption it only ever runs once.

## Rate limiting

Rails 8's built-in `rate_limit` controller macro (or Rack::Attack for
finer-grained rules) on any endpoint that triggers an expensive or
externally billed operation (search, email send, external API call) —
never leave such an endpoint uncapped.
