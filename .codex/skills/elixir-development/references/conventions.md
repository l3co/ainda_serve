# Elixir Conventions Reference

## Naming

| Construct | Convention | Example |
|---|---|---|
| Modules | `CamelCase` | `MyApp.OrderService` |
| Functions and variables | `snake_case` | `calculate_total/1` |
| Macros | `snake_case` | `defmodule`, `use`, `import` |
| Atoms | `snake_case` | `:ok`, `:not_found`, `:invalid_params` |
| Boolean-returning functions | `?` suffix | `valid?/1`, `active?/1` |
| Side-effecting functions (bang) | `!` suffix | `Repo.get!/2`, `fetch!/1` |
| Constants / module attributes | `@screaming_snake_case` | `@max_retries 3` |
| Predicate guards | `is_` prefix | `is_integer/1`, `is_nil/1` |

`!` functions raise on failure. Non-`!` functions return `{:ok, value}` or `{:error, reason}`. Use `!` only at boundaries where failure is unrecoverable (e.g., application startup).

---

## Module Structure

Organize a module in this order:

1. `@moduledoc`
2. `use`, `import`, `alias`, `require` (grouped, sorted)
3. `@type`, `@typep`, `@opaque`
4. `@behaviour` declarations
5. Module attributes (`@const`, `@default_timeout`, etc.)
6. `defstruct` (if applicable)
7. Public functions with `@doc` and `@spec`
8. Private functions (`defp`)
9. `@impl` callbacks (GenServer, Behaviour)

Group aliases alphabetically. Separate `use`/`import` from `alias`/`require` with a blank line.

```elixir
defmodule MyApp.Accounts do
  @moduledoc "Public API for the Accounts context."

  import Ecto.Query, only: [from: 2, where: 3]

  alias MyApp.Accounts.{User, UserToken}
  alias MyApp.Repo

  @type email :: String.t()
  @type create_result :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}

  @doc "Creates a new user with the given attributes."
  @spec create_user(map()) :: create_result()
  def create_user(attrs) do
    ...
  end
end
```

---

## Pattern Matching

Pattern matching is the primary control flow mechanism. Use it for:

- Destructuring function arguments
- Guards on multiple cases
- `case`, `cond`, and `with` expressions

Prefer pattern matching in function heads over conditionals in the body:

```elixir
# Preferred
def process({:ok, value}), do: handle(value)
def process({:error, reason}), do: log_error(reason)

# Avoid
def process(result) do
  if match?({:ok, _}, result), do: ...
end
```

Use `_` for ignored values. Use `_name` for ignored values where the name adds clarity for the reader.

---

## Pipe Operator

Use `|>` for sequential transformations of a single data value:

```elixir
def register_user(attrs) do
  attrs
  |> normalize_email()
  |> validate_password_strength()
  |> create_user_changeset()
  |> Repo.insert()
end
```

Do not use the pipe operator when the chain requires branching or when intermediate failures must be handled differently — use `with` instead.

Do not start a pipe chain with a value that requires parentheses: `(a + b) |> f()` — extract to a variable.

---

## with for Sequential Fallible Operations

```elixir
def place_order(user_id, cart_id) do
  with {:ok, user} <- Accounts.get_user(user_id),
       {:ok, cart} <- Cart.get_active(cart_id),
       :ok <- Cart.belongs_to?(cart, user),
       {:ok, order} <- Orders.create_from_cart(user, cart) do
    {:ok, order}
  else
    {:error, :not_found} -> {:error, :user_not_found}
    {:error, :cart_empty} -> {:error, :cannot_checkout_empty_cart}
    {:error, changeset} -> {:error, {:validation, changeset}}
  end
end
```

Always include an `else` clause when error values differ between steps. Without `else`, all errors pass through unchanged — valid only when errors are uniform.

---

## Error Handling

All functions that can fail MUST return `{:ok, value}` or `{:error, reason}`.

```elixir
# Correct
def find_user(id) do
  case Repo.get(User, id) do
    %User{} = user -> {:ok, user}
    nil -> {:error, :not_found}
  end
end

# Incorrect — returning nil forces callers to guess the failure mode
def find_user(id), do: Repo.get(User, id)
```

`raise` / `throw` / `exit` are for unrecoverable programmer errors or OTP signals — not for domain failures.

---

## Changesets

Every external input that mutates data goes through a changeset:

```elixir
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :hashed_password, :string
    field :role, Ecto.Enum, values: [:admin, :member]
    timestamps()
  end

  @required_fields ~w(email hashed_password)a
  @optional_fields ~w(role)a

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_length(:hashed_password, min: 8)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{hashed_password: pw}} = cs) do
    change(cs, hashed_password: Argon2.hash_pwd_salt(pw))
  end
  defp put_password_hash(changeset), do: changeset
end
```

`cast/3` only accepts listed fields. `validate_required/2` ensures they are present. Always validate before transforming.

---

## Typespecs

All public module functions MUST have `@spec`:

```elixir
@spec calculate_total([OrderItem.t()]) :: {:ok, Money.t()} | {:error, :empty_items}
def calculate_total([]), do: {:error, :empty_items}
def calculate_total(items) do
  total = Enum.reduce(items, Money.zero(:BRL), &Money.add(&2, &1.price))
  {:ok, total}
end
```

Run Dialyzer (`mix dialyzer`) regularly. Address hard-typed warnings; ignore unknown function warnings only when using dynamic dispatch patterns intentionally.

---

## Observability

Use `Logger` with structured metadata:

```elixir
require Logger

def process_order(order) do
  Logger.metadata(order_id: order.id, customer_id: order.customer_id)
  Logger.info("processing order")
  # ...
  Logger.info("order processed successfully")
end
```

Use `:telemetry` events for measurable operations:

```elixir
:telemetry.execute(
  [:my_app, :order, :created],
  %{count: 1},
  %{order_id: order.id, customer_id: order.customer_id}
)
```

Define telemetry event names following `[:app, :domain, :event]` convention. Attach handlers in the Application module or a dedicated telemetry handler module.

MUST NOT log passwords, tokens, personal identifiers, or raw request bodies.
