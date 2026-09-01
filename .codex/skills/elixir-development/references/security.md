# Elixir Security Reference

## Atom Exhaustion

MUST NOT create atoms from untrusted user input. The BEAM atom table is limited and atoms are never garbage collected.

```elixir
# Incorrect — creates an atom from user input; can exhaust the atom table.
def get_role(input), do: String.to_atom(input)

# Correct — validates against a known set using String.to_existing_atom/1
# or an explicit allowlist.
@valid_roles ~w(admin member viewer)

def parse_role(input) when input in @valid_roles do
  {:ok, String.to_existing_atom(input)}
end
def parse_role(_), do: {:error, :invalid_role}
```

Never use `:"#{user_input}"` or `String.to_atom/1` with data from external sources.

---

## Ecto and SQL Injection

Ecto's query DSL and parameterized bindings prevent SQL injection by design. MUST use them.

```elixir
# Correct — parameterized binding; Ecto escapes the value.
def find_by_email(email) do
  Repo.get_by(User, email: email)
end

# Correct — dynamic query with parameterized fragment.
def search_users(term) do
  from(u in User, where: ilike(u.name, ^"%#{term}%"))
  |> Repo.all()
end

# Incorrect — never interpolate into a raw SQL fragment.
# Repo.query!("SELECT * FROM users WHERE email = '#{email}'")
```

MUST NOT use `Repo.query/2` with string interpolation of user input.

MUST use `fragment/1` with parameterized bindings when raw SQL expressions are necessary.

---

## Input Validation with Changesets

All external input that modifies data MUST pass through a changeset before reaching the database.

```elixir
def registration_changeset(user, attrs) do
  user
  |> cast(attrs, [:email, :password])
  |> validate_required([:email, :password])
  |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
  |> validate_length(:password, min: 12)
  |> unique_constraint(:email)
end
```

Never pass `attrs` directly to `Repo.insert/1` or `Repo.update/1` without casting.

---

## Password Storage

MUST NOT store passwords in plain text.

MUST use a strong adaptive hashing algorithm: `Argon2`, `Bcrypt`, or `Pbkdf2`.

```elixir
# Using Argon2 (argon2_elixir library)
def put_password_hash(changeset) do
  case changeset do
    %Ecto.Changeset{valid?: true, changes: %{password: pw}} ->
      change(changeset, hashed_password: Argon2.hash_pwd_salt(pw))
    _ ->
      changeset
  end
end
```

MUST use constant-time comparison when verifying passwords: `Argon2.verify_pass/2`.

MUST NOT store the raw password after hashing. Remove it from the changeset or struct before persisting or logging.

---

## Secrets Management

MUST NOT commit secrets to version control.

MUST NOT place secrets in `config/config.exs`, `config/dev.exs`, or `config/prod.exs` (compile-time config).

MUST use `config/runtime.exs` for secrets and environment-specific configuration:

```elixir
# config/runtime.exs
import Config

config :my_app, MyApp.Repo,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :my_app, :stripe_secret_key, System.fetch_env!("STRIPE_SECRET_KEY")
```

Use `System.fetch_env!/1` to fail fast at startup if a required variable is missing.

MUST NOT log secret values. Mask them in any debugging output.

---

## Phoenix XSS Protection

HEEx templates escape HTML by default. MUST NOT use `raw/1` with unsanitized user content.

```elixir
# Correct — HEEx escapes this automatically.
<p>{@user.bio}</p>

# Incorrect — renders raw HTML, bypassing escaping.
<p>{raw(@user.bio)}</p>
```

When rich text is required, sanitize with a trusted library (e.g., `HtmlSanitizeEx`) before passing to `raw/1`.

---

## Phoenix CSRF Protection

Phoenix includes CSRF protection via `Plug.CSRFProtection` in the browser pipeline. MUST NOT remove it.

Forms must include the CSRF token:

```elixir
# Phoenix form helpers include the CSRF token automatically.
<.form for={@changeset} action={~p"/orders"}>
  ...
</.form>
```

For JSON API endpoints, CSRF is typically not needed (stateless authentication), but session-based APIs MUST keep CSRF protection.

---

## Authentication and Authorization

MUST verify the current user's identity on every request that accesses protected resources.

MUST NOT trust user-supplied identifiers (e.g., user_id in the request body) as the subject. Use the session or token to determine the authenticated identity.

```elixir
# Incorrect — trusts the user_id from the request body.
def show(conn, %{"user_id" => user_id}) do
  user = Accounts.get_user!(user_id)
  render(conn, :show, user: user)
end

# Correct — uses the authenticated user from the connection assigns.
def show(conn, _params) do
  render(conn, :show, user: conn.assigns.current_user)
end
```

MUST check ownership or access rights before returning or modifying a resource.

MUST NOT return a resource solely because its identifier is known (IDOR).

---

## File Uploads

MUST validate file type by content, not only by file extension.

MUST NOT store uploaded files with user-provided filenames.

MUST restrict upload size at the plug level before processing.

MUST store uploaded files outside the web root or use object storage (e.g., S3, GCS).

---

## Dependencies

MUST review dependencies for known vulnerabilities using `mix deps.audit` or equivalent.

MUST NOT use abandoned or unmaintained packages for security-critical features (auth, crypto, parsing).

SHOULD pin dependency versions in `mix.lock` and review diffs on update.

---

## Logging

MUST NOT log passwords, tokens, keys, or personal identifiers.

MUST NOT log full request params when they may contain sensitive fields.

```elixir
# Incorrect — logs the raw params including potential passwords.
Logger.debug("request params: #{inspect(params)}")

# Correct — log only what is necessary and safe.
Logger.info("user login attempt", email: params["email"])
```

Use `Logger.metadata/1` to attach correlation identifiers without logging sensitive values.
