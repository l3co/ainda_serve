# Ruby/Rails Testing Reference

Default to **RSpec** unless the project already uses **Minitest** (Rails'
own default) — both are equally valid; follow whatever the project has
already chosen rather than introducing a second framework. Examples below
use RSpec; the same principles apply directly to Minitest.

## Test types and where they belong

| Type | Tool | Tests |
|---|---|---|
| Unit (PORO) | RSpec, no Rails/DB needed | Pure objects: `Sm2Scheduler`, value objects, calculators |
| Model spec | RSpec + FactoryBot, real test DB | ActiveRecord model behavior: validations, associations, domain methods, scopes |
| Request spec | RSpec request specs | Controller actions via real HTTP-shaped requests: status codes, JSON shape, redirects, auth/ownership failures |
| System spec | RSpec + Capybara (`cuprite`/`selenium` headless) | End-to-end Hotwire flows: a real browser-like session clicking through Turbo Frames/Streams |
| External integration | RSpec + `WebMock`/`VCR` | HTTP clients wrapping third-party APIs — real network calls never happen in the suite |

---

## Unit-testing plain Ruby objects

The whole point of extracting a PORO (see
[architecture.md](architecture.md)) is that it's testable without
`ActiveRecord` or a database at all:

```ruby
RSpec.describe Sm2Scheduler do
  describe ".reschedule" do
    it "increases the interval on a high-quality review" do
      card = FlashcardState.new(ease_factor: 2.5, interval_days: 6, repetitions: 2)

      result = Sm2Scheduler.reschedule(card, quality: 5)

      expect(result.interval_days).to be > 6
    end

    it "resets repetitions on a failed review" do
      card = FlashcardState.new(ease_factor: 2.5, interval_days: 6, repetitions: 2)

      result = Sm2Scheduler.reschedule(card, quality: 2)

      expect(result.repetitions).to eq(0)
    end
  end
end
```

If a "unit" test needs `ActiveRecord::Base.transaction` or a real
database row to run, it isn't testing a unit in isolation — that's a
model spec, not a PORO spec.

---

## Model specs

Use FactoryBot for setup, not fixtures — factories compose better across
tests with different starting states:

```ruby
RSpec.describe Session, type: :model do
  describe "#pause" do
    it "records the paused timestamp and transitions status" do
      session = create(:session, status: :in_progress)

      session.pause

      expect(session).to be_paused
      expect(session.paused_at).to be_present
    end

    it "raises when the session isn't in progress" do
      session = create(:session, status: :completed)

      expect { session.pause }.to raise_error(Session::InvalidTransitionError)
    end
  end
end
```

**Test every legal transition and at least one illegal one** for any
state-carrying model (see the enum + guard pattern in
[architecture.md](architecture.md)) — the guard clauses are the part most
likely to silently rot if untested.

---

## Request specs

Test the HTTP contract, not the internals:

```ruby
RSpec.describe "Api::V1::Orders", type: :request do
  describe "POST /api/v1/orders" do
    it "creates an order for the authenticated user" do
      user = create(:user)

      post "/api/v1/orders", params: { order: { book_id: create(:book).id } },
                              headers: bearer_auth(user)

      expect(response).to have_http_status(:created)
      expect(json_response["status"]).to eq("to_read")
    end

    it "returns 401 without a token" do
      post "/api/v1/orders", params: { order: { book_id: create(:book).id } }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 when acting on another user's resource" do
      owner = create(:user)
      other = create(:user)
      order = create(:order, user: owner)

      patch "/api/v1/orders/#{order.id}", params: { order: { status: "read" } },
                                            headers: bearer_auth(other)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
```

Always cover the ownership/authorization failure path alongside the happy
path — a resource endpoint without a "wrong user" test is not fully
tested.

---

## System specs (Hotwire flows)

Exercise a real page, including Turbo behavior:

```ruby
RSpec.describe "Club messages", type: :system, js: true do
  it "appends a new message via Turbo Stream without a full reload" do
    user = create(:user)
    club = create(:club)
    create(:club_membership, user:, club:, status: :active)
    sign_in user

    visit club_path(club)
    fill_in "message_content", with: "Just finished chapter 3!"
    click_button "Post"

    expect(page).to have_content("Just finished chapter 3!")
  end
end
```

Reserve `js: true` (a real headless browser driver) for flows that
actually depend on Turbo Stream/Frame behavior or Stimulus interaction —
a plain form submission with a full-page redirect doesn't need it and
runs faster as a request spec instead.

---

## Stubbing external integrations

Never make a real HTTP call in the test suite (shared guardrail:
"external services — must not make real external calls in unit tests").
Use `WebMock` for simple stubs, `VCR` when the response shape is complex
enough that a recorded cassette is clearer than a hand-written stub:

```ruby
RSpec.describe YouTube::Client do
  it "returns an empty list when the API key is missing" do
    allow(Rails.application.credentials).to receive(:youtube_api_key).and_return(nil)

    result = described_class.new.search_for_book(title: "Mero Cristianismo")

    expect(result).to eq([])
  end

  it "parses a successful response", vcr: { cassette_name: "youtube_search_success" } do
    result = described_class.new.search_for_book(title: "Mero Cristianismo")

    expect(result.first.platform).to eq("youtube")
  end
end
```

Every external client needs at least one test for its failure path
(timeout, non-2xx response, malformed body) returning the documented
fallback (empty result, raised domain error) — not just the happy path.

---

## Testing duck-typed interfaces

When several classes implement the same informal interface (e.g., several
notification channels each responding to `#deliver`), use a shared
example group so every implementer is checked against the same contract
instead of duplicating the same assertions per class:

```ruby
RSpec.shared_examples "a notification channel" do
  it "responds to #deliver" do
    expect(subject).to respond_to(:deliver)
  end
end

RSpec.describe InAppChannel do
  it_behaves_like "a notification channel"
end
```

Only introduce this once a second real implementer exists — writing the
shared example for a single class is the same premature abstraction this
skill otherwise argues against (see the Rule of Three in `SKILL.md`).

---

## Coverage philosophy

No coverage percentage is tracked as a goal in itself, per the shared
guardrails. What must have a test:

- Every domain method that changes state (`finish_reading`, `cancel`,
  `pause`) — happy path and at least one guard/failure path.
- Every branch in a PORO with real logic (SM-2 math, reward threshold
  evaluation).
- Every controller action's authorization boundary (unauthenticated,
  wrong-owner).
- Every external client's failure/fallback path.

A regression fix is not complete without a test that would have caught
it, when adding one is feasible — matching the shared guardrail against
declaring a fix done without a reproducing test.
