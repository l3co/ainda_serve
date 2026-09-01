# Elixir Idiomatic Examples

Short, focused examples. Not a complete application — reference patterns only.

---

## Value Object with Embedded Schema

```elixir
defmodule MyApp.Money do
  @moduledoc "Immutable value object representing a monetary amount."

  @enforce_keys [:amount_in_cents, :currency]
  defstruct [:amount_in_cents, :currency]

  @type t :: %__MODULE__{amount_in_cents: non_neg_integer(), currency: String.t()}

  @spec new(non_neg_integer(), String.t()) :: {:ok, t()} | {:error, String.t()}
  def new(amount, currency) when is_integer(amount) and amount >= 0 and is_binary(currency) do
    {:ok, %__MODULE__{amount_in_cents: amount, currency: currency}}
  end
  def new(amount, _) when is_integer(amount) and amount < 0 do
    {:error, "amount must be non-negative"}
  end
  def new(_, _), do: {:error, "invalid amount or currency"}

  @spec add(t(), t()) :: {:ok, t()} | {:error, String.t()}
  def add(%__MODULE__{currency: c} = a, %__MODULE__{currency: c} = b) do
    {:ok, %__MODULE__{amount_in_cents: a.amount_in_cents + b.amount_in_cents, currency: c}}
  end
  def add(_, _), do: {:error, "cannot add amounts with different currencies"}
end
```

---

## GenServer with Client API

```elixir
defmodule MyApp.PriceCache do
  @moduledoc "In-memory cache for product prices with TTL support."

  use GenServer

  @default_ttl_ms 60_000

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @spec get(GenServer.server(), String.t()) :: {:ok, non_neg_integer()} | {:error, :not_found}
  def get(server, product_id) do
    GenServer.call(server, {:get, product_id})
  end

  @spec put(GenServer.server(), String.t(), non_neg_integer()) :: :ok
  def put(server, product_id, price) do
    GenServer.cast(server, {:put, product_id, price})
  end

  # Server callbacks

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:get, id}, _from, state) do
    case Map.get(state, id) do
      {price, expires_at} when expires_at > System.monotonic_time(:millisecond) ->
        {:reply, {:ok, price}, state}
      _ ->
        {:reply, {:error, :not_found}, Map.delete(state, id)}
    end
  end

  @impl true
  def handle_cast({:put, id, price}, state) do
    expires_at = System.monotonic_time(:millisecond) + @default_ttl_ms
    {:noreply, Map.put(state, id, {price, expires_at})}
  end
end
```

---

## Ecto Schema and Changeset

```elixir
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :hashed_password, :string
    field :role, Ecto.Enum, values: [:admin, :member], default: :member
    field :active, :boolean, default: true
    timestamps()
  end

  @type t :: %__MODULE__{
    id: integer() | nil,
    email: String.t() | nil,
    hashed_password: String.t() | nil,
    role: :admin | :member,
    active: boolean()
  }

  @spec registration_changeset(t(), map()) :: Ecto.Changeset.t()
  def registration_changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_length(:password, min: 12, message: "must be at least 12 characters")
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: pw}} = cs) do
    change(cs, hashed_password: Argon2.hash_pwd_salt(pw))
  end
  defp put_password_hash(changeset), do: changeset
end
```

---

## Context Module

```elixir
defmodule MyApp.Accounts do
  @moduledoc "Public API for account management."

  alias MyApp.Accounts.User
  alias MyApp.Repo

  @spec get_user(integer()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(id) do
    case Repo.get(User, id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec authenticate(String.t(), String.t()) :: {:ok, User.t()} | {:error, :invalid_credentials}
  def authenticate(email, password) do
    with %User{} = user <- Repo.get_by(User, email: email, active: true),
         true <- Argon2.verify_pass(password, user.hashed_password) do
      {:ok, user}
    else
      _ -> {:error, :invalid_credentials}
    end
  end
end
```

---

## with for Sequential Fallible Operations

```elixir
def place_order(user_id, cart_id) do
  with {:ok, user} <- Accounts.get_user(user_id),
       {:ok, cart} <- Cart.get_active(cart_id),
       :ok <- Cart.verify_ownership(cart, user),
       {:ok, order} <- Orders.create_from_cart(user, cart),
       :ok <- Payments.charge(user, order) do
    {:ok, order}
  else
    {:error, :not_found} -> {:error, :user_or_cart_not_found}
    {:error, :cart_empty} -> {:error, :cannot_checkout_empty_cart}
    {:error, :unauthorized} -> {:error, :cart_does_not_belong_to_user}
    {:error, :payment_declined} -> {:error, :payment_declined}
    {:error, changeset} -> {:error, {:validation, changeset}}
  end
end
```

---

## Ecto Query Composition

```elixir
import Ecto.Query

def list_active_orders(filters \\ []) do
  Order
  |> where([o], o.status == :active)
  |> apply_filters(filters)
  |> order_by([o], desc: o.inserted_at)
  |> Repo.all()
end

defp apply_filters(query, []), do: query
defp apply_filters(query, [{:customer_id, id} | rest]) do
  query |> where([o], o.customer_id == ^id) |> apply_filters(rest)
end
defp apply_filters(query, [{:min_total, amount} | rest]) do
  query |> where([o], o.total_in_cents >= ^amount) |> apply_filters(rest)
end
defp apply_filters(query, [_ | rest]), do: apply_filters(query, rest)
```

---

## ExUnit Test

```elixir
defmodule MyApp.PricingTest do
  use ExUnit.Case, async: true

  alias MyApp.Pricing

  describe "apply_discount/2" do
    test "reduces the price by the given rate" do
      assert Pricing.apply_discount(1000, 0.10) == 900
    end

    test "returns the original price when rate is 0" do
      assert Pricing.apply_discount(500, 0.0) == 500
    end

    test "returns 0 when rate is 1.0" do
      assert Pricing.apply_discount(1000, 1.0) == 0
    end

    test "returns error when rate is negative" do
      assert {:error, _} = Pricing.apply_discount(1000, -0.1)
    end
  end
end
```

---

## Elixir-Specific Anti-Patterns

### Atom from User Input

```elixir
# Anti-pattern: creates an atom from external input — can exhaust the atom table.
def set_role(user, role_string) do
  %{user | role: String.to_atom(role_string)}
end

# Correct: validate against an allowlist first.
@valid_roles ~w(admin member viewer)a

def set_role(user, role_string) when role_string in ~w(admin member viewer) do
  {:ok, %{user | role: String.to_existing_atom(role_string)}}
end
def set_role(_, _), do: {:error, :invalid_role}
```

### GenServer for Simple State

```elixir
# Anti-pattern: a GenServer that just wraps a map lookup available in the caller.
defmodule TaxRateRegistry do
  use GenServer
  def get(country), do: GenServer.call(__MODULE__, {:get, country})
  def handle_call({:get, country}, _from, rates), do: {:reply, Map.get(rates, country), rates}
end

# Correct: a module attribute is sufficient when rates are static.
@tax_rates %{"BR" => 0.17, "US" => 0.08}
def tax_rate(country), do: Map.get(@tax_rates, country, 0.0)
```

### Missing else in with

```elixir
# Anti-pattern: errors from different steps look identical to the caller.
def checkout(user_id, cart_id) do
  with {:ok, user} <- get_user(user_id),
       {:ok, cart} <- get_cart(cart_id) do
    process(user, cart)
  end
  # {:error, :not_found} could come from either step — caller cannot distinguish
end

# Correct: disambiguate errors in the else clause.
def checkout(user_id, cart_id) do
  with {:ok, user} <- get_user(user_id),
       {:ok, cart} <- get_cart(cart_id) do
    process(user, cart)
  else
    {:error, :not_found} when is_binary(user_id) -> {:error, :user_not_found}
    {:error, :not_found} -> {:error, :cart_not_found}
  end
end
```

### Ignoring Changeset Errors

```elixir
# Anti-pattern: inserts without checking changeset validity.
def create_user(attrs) do
  changeset = User.registration_changeset(%User{}, attrs)
  Repo.insert(changeset)
  # Caller never gets {:error, changeset} — errors are silently dropped
end

# Correct: return the result so callers can handle validation errors.
def create_user(attrs) do
  %User{}
  |> User.registration_changeset(attrs)
  |> Repo.insert()
end
```

### Long Function Head Guards Instead of Pattern Matching

```elixir
# Anti-pattern: complex conditional in one function head.
def process(order) do
  if order.status == :pending and order.total > 0 and length(order.items) > 0 do
    charge(order)
  else
    {:error, :not_processable}
  end
end

# Correct: multiple function clauses with guards for clarity.
def process(%{status: :pending, total: total, items: [_ | _]} = order) when total > 0 do
  charge(order)
end
def process(_order), do: {:error, :not_processable}
```
