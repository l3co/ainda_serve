# Ruby/Rails Conventions Reference

## Naming

| Construct | Convention | Example |
|---|---|---|
| Classes and modules | `CamelCase` | `Club::Membership`, `Sm2Scheduler` |
| Methods and variables | `snake_case` | `calculate_total` |
| Predicate methods (return boolean) | `?` suffix | `active?`, `shipped?`, `concept?` |
| Dangerous/mutating methods (raise, or mutate in place where a non-`!` sibling exists) | `!` suffix | `save!`, `update!`, `finish!` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES = 3` |
| File names | `snake_case`, matching the constant they define | `club/schedule.rb` → `Club::Schedule` |

A `!` method either raises where its non-`!` sibling returns `false`/`nil`
(`save!` vs `save`), or signals "this mutates and you should pay
attention" when there's no non-mutating sibling at all (`finish!`). Do not
add `!` to a method just because it changes state — only when the bang
carries real information (danger, or "vs the safe version").

---

## File and class organization

Order within a class, top to bottom:

```ruby
class Order < ApplicationRecord
  # 1. module inclusion
  include Eventable

  # 2. constants
  MAX_ITEMS = 50

  # 3. associations
  belongs_to :user
  has_many :order_items, dependent: :destroy

  # 4. validations
  validates :status, presence: true

  # 5. scopes
  scope :recent, -> { order(created_at: :desc) }

  # 6. callbacks (sparingly — see below)
  after_commit :dispatch_events

  # 7. class methods
  def self.for_user(user) = where(user:)

  # 8. public instance methods
  def cancel
    ...
  end

  private

  # 9. private instance methods
  def dispatch_events
    ...
  end
end
```

---

## Duck typing over type checks

Never branch on an object's class or a redundant type string from the
outside:

```ruby
# Avoid
def process(payment)
  case payment
  when CreditCardPayment then charge_card(payment)
  when PixPayment then charge_pix(payment)
  end
end

# Prefer — the object answers the message
def process(payment)
  payment.charge
end
```

If the "kind" is a stored attribute (a Rails `enum`, not a class), the
attribute itself should answer questions, not be inspected from outside:

```ruby
# Avoid
if flashcard.card_type == "concept"
  ...
end

# Prefer
if flashcard.concept?
  ...
end
```

---

## Error handling

- **Raise for programmer errors and invariant violations** — an illegal
  state transition, a required argument missing, a contract violated by
  the caller. Define narrow, named exception classes per failure mode, not
  one generic error reused everywhere:

  ```ruby
  class Session
    class AlreadyFinishedError < StandardError; end

    def finish
      raise AlreadyFinishedError, "session #{id} already finished" if finished?
      ...
    end
  end
  ```

- **Return `nil`/`false`, or an explicit result, for expected absence or
  expected failure** — "user not found," "form invalid" are not
  exceptional, they're expected outcomes a caller should handle inline:

  ```ruby
  def find_active_user(id)
    User.active.find_by(id: id)  # nil is a legitimate answer here
  end
  ```

- **Never rescue broadly** (`rescue StandardError`/`rescue Exception`)
  without a documented reason and a narrower rescue where the actual
  failure mode is known. A blanket rescue at a system boundary (a
  background job's top-level error handler, a controller's
  `rescue_from`) is legitimate; a blanket rescue three calls deep inside
  business logic almost never is.

- **Never swallow an exception silently.** Log with context, re-raise, or
  handle it in a way that changes program behavior meaningfully — an empty
  `rescue => e; end` hides the actual failure from everyone who needs to
  know about it.

---

## ActiveRecord conventions

- **Strong parameters always** — never mass-assign from raw `params`.
- **Scopes for reusable query fragments**, class methods for anything that
  needs more than a `where`/`order` one-liner or that composes several
  scopes with real logic.
- **Callbacks sparingly.** A callback that reaches into another model
  (`after_save { other_model.update! }`) is a coupling smell — prefer the
  "collect and dispatch" event pattern (see
  [architecture.md](architecture.md)) so the triggering model doesn't need
  to know what reacts to it.
- **Avoid N+1 queries** — use `includes`/`preload`/`eager_load`
  deliberately wherever a collection renders associated data; a bulleted
  list view that queries once per row is a bug, not a later optimization.
- **Migrations are additive and reversible** by default — a destructive
  migration (dropping a column/table in the same deploy that stops using
  it) needs an explicit transition plan, matching the shared guardrails on
  database and persistence.

---

## Controllers

- Keep actions thin: fetch/authorize, call the model or PORO, render. A
  controller action doing multi-step orchestration is a sign that logic
  belongs in a model method or a PORO instead.
- Use `before_action` for setup shared across actions in the same
  controller (`set_order`, `authenticate_user!`) — not for logic specific
  to one action.
- One controller per resource; a controller with actions that don't map to
  a RESTful resource (`index`/`show`/`create`/`update`/`destroy`, plus the
  occasional resource-scoped custom action) is a sign the resource
  boundary is wrong, not that the controller needs more actions.

---

## Hotwire view conventions

- Partial names describe the thing they render (`_order.html.erb`), not
  the page that happens to include them first.
- A `create.turbo_stream.erb` (or equivalent) template renders exactly the
  update the action caused — do not render unrelated page regions "while
  we're at it."
- Stimulus controller file names match their `data-controller` value
  (`countdown_controller.js` → `data-controller="countdown"`), one
  concern per controller.

---

## Observability

`Logger#info`/`#error`/etc. take **one** positional argument (message or
progname), not keyword args — `logger.info("event", key: value)` raises
`ArgumentError: wrong number of arguments`, it does not log structured
data. Pass a single Hash literal instead when you want key/value context
alongside an event name:

```ruby
Rails.logger.info({ event: "order.shipped", order_id: order.id, user_id: order.user_id })
```

This is plain Ruby `Logger` behavior, not a Rails limitation — verify
against the project's actual logger (some apps swap in `lograge`,
`semantic_logger`, or a custom JSON formatter that changes what a single
call can accept) rather than assuming either shape works everywhere.

Never log passwords, tokens, or other sensitive personal data. Never use
logging as a substitute for proper error handling — a `rescue` that only
logs and continues is usually hiding a failure the caller needed to know
about.
