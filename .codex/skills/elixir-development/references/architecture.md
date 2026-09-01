# Elixir Architecture Reference

## OTP Application Structure

An Elixir project is an OTP application. The entry point is the `Application` module defined in `mix.exs`.

```
lib/
├── my_app/
│   ├── application.ex        # Application.start/2, root supervisor
│   ├── repo.ex               # Ecto.Repo (if using Ecto)
│   └── ...                   # domain modules
├── my_app.ex                 # top-level module, public API façade
test/
├── my_app/
│   └── ...
├── support/                  # shared test helpers, factories
└── test_helper.exs
mix.exs
config/
├── config.exs                # compile-time, non-secret configuration
├── dev.exs
├── test.exs
├── prod.exs
└── runtime.exs               # runtime secrets and environment-specific config
```

The root supervisor defines the child specification order. Children started earlier are stopped later (LIFO). Depend on this order for Repo, PubSub, and Endpoint startup sequencing.

---

## Supervision Trees

Every long-lived process belongs to a supervision tree.

```
Application
└── RootSupervisor (strategy: :one_for_one)
    ├── MyApp.Repo
    ├── MyApp.PubSub
    ├── MyApp.WorkerSupervisor (strategy: :one_for_one)
    │   ├── MyApp.Worker.NotificationWorker
    │   └── MyApp.Worker.EmailWorker
    └── MyAppWeb.Endpoint
```

**Restart strategies:**

| Strategy | When to use |
|---|---|
| `:one_for_one` | Children are independent — default for most supervisors |
| `:one_for_all` | Children are tightly coupled — restarting one requires all |
| `:rest_for_one` | Children depend on previous ones — restart from the failed one forward |

**Choose the restart strategy based on actual dependency, not convention.**

---

## GenServer

Use a GenServer when you need one of:

1. Long-lived state that must persist across function calls
2. Serialized access to a resource
3. Background work with a lifecycle
4. Caching with eviction or TTL

Do not use a GenServer when a plain module function and a data structure argument would solve the problem.

```elixir
defmodule MyApp.PriceCache do
  use GenServer

  # Client API
  def start_link(opts), do: GenServer.start_link(__MODULE__, %{}, opts)
  def get(pid, product_id), do: GenServer.call(pid, {:get, product_id})
  def put(pid, product_id, price), do: GenServer.cast(pid, {:put, product_id, price})

  # Server callbacks
  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:get, id}, _from, state), do: {:reply, Map.get(state, id), state}

  @impl true
  def handle_cast({:put, id, price}, state), do: {:noreply, Map.put(state, id, price)}
end
```

**`call` vs `cast`:**
- `call` — synchronous, the caller waits for a reply; use when the result is needed or back-pressure matters
- `cast` — asynchronous, fire-and-forget; use only when the caller does not care about the result or timing

---

## Phoenix Application Structure

```
lib/
├── my_app/                   # domain layer — pure Elixir, no web concerns
│   ├── accounts/
│   │   ├── accounts.ex       # context module — public API
│   │   ├── user.ex           # Ecto schema
│   │   └── user_token.ex
│   └── orders/
│       ├── orders.ex
│       ├── order.ex
│       └── order_item.ex
├── my_app_web/               # web layer — Phoenix-specific
│   ├── controllers/
│   ├── live/                 # LiveView modules
│   ├── components/           # function components, layouts
│   ├── router.ex
│   └── endpoint.ex
```

**Contexts** are the boundary between the web layer and the domain. A context module exposes public functions; its internal schemas and queries are private.

**The web layer must not access Ecto schemas directly** — it goes through context functions.

---

## Phoenix Contexts

A context is a plain Elixir module that encapsulates a domain boundary.

```elixir
defmodule MyApp.Accounts do
  alias MyApp.Accounts.{User, UserToken}
  alias MyApp.Repo

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    with %User{} = user <- Repo.get_by(User, email: email),
         true <- Argon2.verify_pass(password, user.hashed_password) do
      {:ok, user}
    else
      _ -> {:error, :invalid_credentials}
    end
  end
end
```

---

## Ecto Layer

```
Schema      — struct mapping to a database table
Changeset   — data validation and transformation pipeline
Query       — composable query building
Repo        — database interaction (insert, update, delete, get, all, one)
Migration   — schema version management
```

Schemas represent data shapes. Changesets represent the intent to change data and carry validation errors. They are separate concerns — one schema can have multiple changesets for different operations.

---

## Task and Agent

**Task** — for one-off async computation with a known completion point.

```elixir
task = Task.async(fn -> compute_report(params) end)
result = Task.await(task, 10_000)
```

**Agent** — for simple shared state with no complex message handling.

```elixir
{:ok, agent} = Agent.start_link(fn -> %{} end)
Agent.update(agent, &Map.put(&1, :key, value))
Agent.get(agent, & &1)
```

Prefer GenServer over Agent when the logic grows beyond simple get/update — Agent callbacks cannot fail gracefully.

---

## Umbrella Projects

Use umbrella projects only when the sub-applications are independently deployable or have strict compile-time dependency isolation requirements. Do not use an umbrella to organize a single application with shared data models — that creates circular dependency pain without real benefit.
