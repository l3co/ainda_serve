# Elixir Testing Reference

## ExUnit Basics

ExUnit is Elixir's built-in test framework. Tests live in `test/` and mirror the `lib/` structure.

```elixir
defmodule MyApp.Accounts.UserTest do
  use ExUnit.Case, async: true

  alias MyApp.Accounts
  alias MyApp.Accounts.User

  describe "create_user/1" do
    test "creates a user with valid attributes" do
      attrs = %{email: "alice@example.com", password: "secret1234"}
      assert {:ok, %User{email: "alice@example.com"}} = Accounts.create_user(attrs)
    end

    test "returns error changeset when email is missing" do
      assert {:error, changeset} = Accounts.create_user(%{password: "secret1234"})
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error changeset when email is already taken" do
      attrs = %{email: "alice@example.com", password: "secret1234"}
      {:ok, _} = Accounts.create_user(attrs)
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
```

Use `describe` blocks to group tests by function or scenario. Name tests as full sentences that describe the expected outcome.

---

## Async Tests

Add `async: true` when the test does not share state with other tests (no database, no global registry, no mutable ETS tables). Database tests using `Ecto.Adapters.SQL.Sandbox` can run async safely.

```elixir
use ExUnit.Case, async: true              # for pure unit tests
use MyApp.DataCase, async: true           # for DB tests using sandbox
use MyAppWeb.ConnCase, async: true        # for Phoenix controller/endpoint tests
```

---

## DataCase for Database Tests

Generate `test/support/data_case.ex` via `mix phx.new` or write it manually:

```elixir
defmodule MyApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApp.Repo
      import Ecto
      import Ecto.Changeset
      import MyApp.DataCase
    end
  end

  setup tags do
    MyApp.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MyApp.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
```

---

## ConnCase for Phoenix Tests

```elixir
defmodule MyAppWeb.OrderControllerTest do
  use MyAppWeb.ConnCase, async: true

  describe "GET /api/orders/:id" do
    test "returns the order when found", %{conn: conn} do
      order = insert(:order)
      conn = get(conn, ~p"/api/orders/#{order.id}")
      assert %{"id" => ^order_id} = json_response(conn, 200)
    end

    test "returns 404 when order not found", %{conn: conn} do
      conn = get(conn, ~p"/api/orders/nonexistent")
      assert json_response(conn, 404)
    end

    test "returns 401 when unauthenticated", %{conn: conn} do
      conn = get(conn, ~p"/api/orders/any")
      assert json_response(conn, 401)
    end
  end
end
```

Use path sigils (`~p"/path"`) when available (Phoenix 1.7+) to catch route errors at compile time.

---

## Mocking with Mox

Use `Mox` for mocking behaviours (not modules directly):

```elixir
# In config/test.exs
config :my_app, :notification_sender, MyApp.Notifications.MockSender

# Define the behaviour
defmodule MyApp.Notifications.Sender do
  @callback send_notification(String.t(), String.t()) :: :ok | {:error, term()}
end

# Define the mock in test/support/mocks.ex
Mox.defmock(MyApp.Notifications.MockSender, for: MyApp.Notifications.Sender)

# Use in tests
defmodule MyApp.NotificationsTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "sends a notification on order creation" do
    expect(MyApp.Notifications.MockSender, :send_notification, fn _recipient, _message ->
      :ok
    end)

    MyApp.Orders.create_order(%{...})
  end
end
```

MUST NOT mock the module under test. Mock only external boundaries.

---

## Doctests

Include doctests for public utility functions:

```elixir
defmodule MyApp.Pricing do
  @doc """
  Applies a discount rate to a price in cents.

  ## Examples

      iex> MyApp.Pricing.apply_discount(1000, 0.10)
      900

      iex> MyApp.Pricing.apply_discount(500, 0.0)
      500

  """
  @spec apply_discount(non_neg_integer(), float()) :: non_neg_integer()
  def apply_discount(price_in_cents, rate) do
    round(price_in_cents * (1 - rate))
  end
end
```

Activate doctests with `doctest MyApp.Pricing` inside a test module. Doctests verify that examples in documentation are accurate and up to date.

---

## Testing GenServers

Test GenServers through their client API, not their callbacks directly:

```elixir
defmodule MyApp.PriceCacheTest do
  use ExUnit.Case, async: true

  alias MyApp.PriceCache

  setup do
    {:ok, pid} = PriceCache.start_link(name: nil)
    %{cache: pid}
  end

  test "returns nil for unknown product", %{cache: cache} do
    assert PriceCache.get(cache, "unknown") == nil
  end

  test "returns the stored price after put", %{cache: cache} do
    PriceCache.put(cache, "product-1", 4999)
    assert PriceCache.get(cache, "product-1") == 4999
  end
end
```

---

## Property-Based Testing with StreamData

For functions with many valid input combinations:

```elixir
use ExUnit.Case
use ExUnitProperties

property "total is always non-negative for valid items" do
  check all items <- list_of(positive_integer(), min_length: 1) do
    {:ok, total} = MyApp.Orders.calculate_total(items)
    assert total >= 0
  end
end
```

Use property tests for data transformations, parsers, and invariants. They are complementary to example-based tests, not a replacement.

---

## Anti-Patterns in Testing

MUST NOT write tests that only test Ecto schema field types without domain logic.

MUST NOT use `Process.sleep/1` to wait for async operations — use `assert_receive`, `Task.await`, or process monitoring.

MUST NOT test private functions directly — test them through the public interface.

MUST NOT use global named processes in async tests (`:name` conflicts between test processes).

MUST NOT assert on string representations of structs (fragile, implementation-specific).

SHOULD NOT use `IO.inspect` as a debugging substitute for assertions.
