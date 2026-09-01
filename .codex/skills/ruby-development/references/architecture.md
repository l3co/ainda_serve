# Ruby/Rails Architecture Reference

## Plain Ruby project layout

```
lib/
├── my_gem.rb                 # top-level require, public API surface
├── my_gem/
│   ├── version.rb
│   └── ...                   # one file per class/module, named after it
spec/                          # or test/
├── my_gem/
│   └── ...
Gemfile
my_gem.gemspec
```

One file per public class or module, named to match
(`lib/my_gem/order.rb` defines `MyGem::Order`). Do not collapse multiple
unrelated classes into one file "for convenience" — file boundaries should
mirror class boundaries.

---

## Rails application layout

```
app/
├── models/
│   ├── user.rb
│   ├── order.rb
│   ├── club/                 # namespace only when genuinely coupled
│   │   ├── schedule.rb        # Club::Schedule
│   │   └── membership.rb      # Club::Membership
│   ├── sm2_scheduler.rb        # PORO — pure algorithm, no ActiveRecord
│   ├── rewards/
│   │   └── evaluator.rb        # Rewards::Evaluator — cross-model query
│   └── stats/
│       └── overview.rb          # Stats::Overview — the one query object for a read model
├── controllers/
│   ├── application_controller.rb
│   ├── orders_controller.rb
│   └── api/v1/
│       └── orders_controller.rb
├── views/
├── javascript/controllers/     # Stimulus controllers
├── jobs/
├── mailers/
```

**Namespace only when it earns its keep.** A namespace for a single class
(`Foo::Bar` with no `Foo::Baz`) is a layer with no responsibility of its
own — the shared guardrails call this out directly. Namespace a bounded
context (`Club::*`) once there are several genuinely coupled classes; keep
everything else flat.

**No `app/services` junk drawer.** The most common Rails anti-pattern this
skill actively pushes back on is a folder of `XyzService` classes that
only delegate to a model — the shared guardrails explicitly forbid
"services that only delegate calls." Default to behavior living on the
model that owns the state (see below); reach for a plain Ruby object only
when the behavior genuinely doesn't belong to one record, and name it
after what it does (`Rewards::Evaluator`, not `RewardService`).

---

## Where behavior belongs

Ask, in order:

1. **Does this behavior belong to one record's state?** Put it on that
   model as an instance method.

   ```ruby
   class Order < ApplicationRecord
     def cancel
       raise AlreadyShippedError if shipped?
       update!(status: :cancelled, cancelled_at: Time.current)
     end
   end
   ```

2. **Is this a pure computation with no persistence dependency?** Extract
   a plain Ruby object (PORO) — testable without a database, reusable
   anywhere.

   ```ruby
   class Sm2Scheduler
     def self.reschedule(card, quality:)
       # pure function of (ease_factor, interval_days, repetitions, quality)
       # → (ease_factor, interval_days, repetitions, next_review_at)
     end
   end
   ```

3. **Does this genuinely span multiple aggregates and can't live on any
   single model?** That's the one legitimate case for a dedicated
   coordinating object — name it for what it computes or decides, not
   generically:

   ```ruby
   class Rewards::Evaluator
     def self.call(user, trigger:)
       # reads across Order, Review, etc.; creates the earned-badge row itself
     end
   end
   ```

A coordinating object like this should still be as small as possible: it
reads across models to make one decision and performs one kind of write.
If it starts orchestrating several unrelated writes across several
contexts, that's a sign that a workflow is being modeled as an object
instead of a domain event with independent subscribers — see below.

---

## The "collect and dispatch" domain-event pattern

When a state change on one model needs to trigger unrelated side effects
in other contexts (awarding a badge, logging an activity, sending a
notification), do not couple the model to all of them via callbacks. The
model records that something happened; a dispatcher decides what to do
about it, after the transaction commits.

```ruby
module Eventable
  extend ActiveSupport::Concern

  included do
    after_commit :dispatch_events
  end

  def emit(event)
    (@domain_events ||= []) << event
  end

  private

  def dispatch_events
    return unless @domain_events

    @domain_events.each { |event| ActiveSupport::Notifications.instrument(event.name, event.to_h) }
    @domain_events = []
  end
end

class Order < ApplicationRecord
  include Eventable

  def ship!
    update!(status: :shipped, shipped_at: Time.current)
    emit(OrderShipped.new(order_id: id, user_id: user_id))
  end
end
```

Subscribers (a job, a mailer trigger, an activity logger) each react to
the event they care about; `Order` never lists them. This keeps
`Order#ship!` honest — it changes state and says what happened, and
nothing more — matching *99 Bottles*' insistence that an object should
have one reason to change.

Use `after_commit`, not `after_save` — side effects (jobs, emails) should
never fire for a transaction that ultimately rolls back.

---

## State handling: enum + guards, not a state-machine gem by default

A handful of states with simple legal transitions belongs on the model as
an `enum` plus guard-clause instance methods that raise on an illegal
transition:

```ruby
class Session < ApplicationRecord
  enum :status, { in_progress: 0, paused: 1, completed: 2, abandoned: 3 }

  def pause
    raise InvalidTransitionError, "can only pause an in-progress session" unless in_progress?
    update!(status: :paused, paused_at: Time.current)
  end
end
```

Do not introduce a state-machine gem (AASM or similar) for this — it's an
abstraction the shared guardrails would flag as unjustified. Escalate only
when a context grows enough parallel or branching states that hand-written
guards stop being clearer than a table-driven state machine — a decision
made from evidence in the actual model, not by default.

---

## Hotwire front-end structure

```
app/views/orders/
├── index.html.erb
├── _order.html.erb            # Turbo Frame-wrapped partial for inline updates
├── create.turbo_stream.erb     # Turbo Stream response for a create action
app/javascript/controllers/
├── countdown_controller.js      # Stimulus — client-only interaction
```

- **Turbo Drive** — default navigation; no special code needed beyond
  normal Rails views.
- **Turbo Frames** — scope a partial update to a named region (inline
  edit, in-place pagination) without hand-written JS.
- **Turbo Streams** — server-initiated updates to already-open pages
  (a new chat message appearing, a notification badge updating) via
  `broadcasts_to` on the model or an explicit
  `Turbo::StreamsChannel.broadcast_*` call from an event subscriber —
  never from inside the model that emitted the event.
- **Stimulus** — client-only behavior with no round trip (a visible
  countdown, a flip-card reveal, debounced input). The server remains the
  source of truth for anything that matters (e.g., a session's actual
  elapsed time is computed server-side on pause/finish; Stimulus only
  renders a ticking clock).

Do not reach for a client-side JS framework (React, Vue, etc.) inside a
Hotwire-based Rails app — that contradicts the point of choosing Hotwire
in the first place. If a page genuinely needs heavy client-side state,
that's a project-level architecture decision to make explicitly, not a
default to slide into one controller action at a time.
