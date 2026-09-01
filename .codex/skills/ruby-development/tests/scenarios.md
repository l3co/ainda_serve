# Ruby/Rails Skill — Evaluation Scenarios

Scenarios to validate that an agent using `ruby-development` behaves
correctly. Each states the request, what a correct response looks like,
and the specific anti-pattern that would indicate the skill wasn't
actually applied.

---

## 1. Activation

**Request:** "Add a method to mark a club as archived."

**Correct:** Activates this skill, inspects the existing `Club` model and
its `close`/existing state-transition methods, adds `archive` following
the same guard-clause shape already in the file.

**Anti-pattern:** Writes generic Ruby without checking existing
conventions in the file, or introduces a new pattern (e.g. a state machine
gem) inconsistent with how `close` is already implemented.

---

## 2. Resisting the service-object reflex

**Request:** "I need logic to move a book from 'reading' to 'read' — where
should that go?"

**Correct:** Recommends a method on the `UserBook`/`Order`-equivalent
model itself (`finish_reading`), explains why (behavior belongs with the
state it changes), and does not propose a `BookFinishingService` class.

**Anti-pattern:** Defaults to creating `app/services/finish_reading_service.rb`
that only calls `user_book.update!(...)`.

---

## 3. Resisting the state-machine gem

**Request:** "This model has four states with a few transitions — should
I add AASM?"

**Correct:** Recommends `enum` + guard-clause instance methods that raise
on an illegal transition, explicitly names AASM as unnecessary for this
scale, and states the concrete condition under which it would reconsider
(many parallel/branching states outgrowing hand-written guards).

**Anti-pattern:** Adds the gem without asking whether the complexity
justifies it, or silently assumes the project wants it.

---

## 4. Duck typing over conditionals

**Request:** "This method has `case payment_method.class when
CreditCard... when Pix...` — can you clean it up?"

**Correct:** Refactors to a shared method (`#charge`) implemented by each
payment method class, and the caller stops inspecting the class entirely.

**Anti-pattern:** Just reformats the `case` statement (e.g., switches to
`case ... when :credit_card`) without removing the type inspection itself.

---

## 5. Rule of Three — not abstracting on the first or second occurrence

**Request:** "Add a second, similar reward check next to the one that
already exists — same shape, different trigger."

**Correct:** Writes the second check with acceptable duplication rather
than immediately extracting a shared abstraction after only two cases;
notes that a third occurrence would be the trigger to extract.

**Anti-pattern:** Extracts a generic `RewardChecker` class from only two
call sites, guessing at a shape neither concrete case has confirmed yet.

---

## 6. Security — mass assignment and ownership

**Request:** "Add an update action for editing a review."

**Correct:** Uses strong parameters (`params.require(:review).permit(...)`),
scopes the record lookup through `current_user.reviews.find(...)` (or an
equivalent explicit ownership check), and does not accept a `user_id`
field from the client.

**Anti-pattern:** `Review.find(params[:id]).update(params[:review])` with
no ownership check and no parameter allowlist.

---

## 7. Security — SQL injection

**Request:** "Add a search filter by title, using a `LIKE` query."

**Correct:** `Book.where("title ILIKE ?", "%#{sanitize_sql_like(query)}%")`
or the query-interface equivalent — parameterized, never raw
interpolation of `query` into the SQL string.

**Anti-pattern:** `Book.where("title ILIKE '%#{query}%'")`.

---

## 8. Testing — external HTTP is stubbed, not called

**Request:** "Write tests for the YouTube search client."

**Correct:** Uses `WebMock`/`VCR` to stub the HTTP call; includes a test
for the failure/empty-result path (missing API key, non-2xx response).

**Anti-pattern:** Test suite makes a real network call to the YouTube API
(flaky, slow, and burns quota), or only covers the happy path.

---

## 9. Testing — state transitions get both paths tested

**Request:** "Write tests for `Session#pause`."

**Correct:** Tests both the successful transition (in_progress → paused)
and the guard failure (raising when called on a non-in-progress session).

**Anti-pattern:** Only tests the happy path, leaving the guard clause
unverified.

---

## 10. N+1 awareness

**Request:** "Render a list of clubs with their owner's name."

**Correct:** Flags/avoids the N+1 by using `includes(:owner)` on the
collection query, or explicitly notes the risk if it can't verify the
view without more context.

**Anti-pattern:** Ships a view that queries the owner association once
per row without comment.

---

## 11. Ambiguous request — ask, don't guess

**Request:** "Make the club feature better."

**Correct:** Asks one focused clarifying question (what specifically:
performance, a missing feature, a bug) rather than picking an arbitrary
interpretation and making a broad, unrequested change.

**Anti-pattern:** Silently refactors unrelated parts of the club feature,
expanding scope beyond what was asked (violates the shared guardrails'
scope protection).

---

## 12. Dependency justification

**Request:** "Add a gem to call this JSON API."

**Correct:** Checks whether `Net::HTTP` (stdlib) or an already-installed
HTTP client in the `Gemfile` already covers the need before proposing a
new gem; if a new gem is genuinely justified (e.g., the API needs
multipart streaming a stdlib client handles awkwardly), states why.

**Anti-pattern:** Adds `httparty`/`faraday`/etc. reflexively without
checking the `Gemfile` first or considering `Net::HTTP` for a simple call.

---

## 13. Splitting a kitchen-sink model

**Request:** "This `Event` model has 20 nullable columns for two very
different kinds of events (in-person vs. virtual) — what would you do?"

**Correct:** Recommends splitting into a base model plus a one-to-one
associated model for the logistics-specific fields (mirroring the
`Club`/`Club::Schedule` split pattern), explains the SRP justification,
and proposes it as an incremental migration, not necessarily a single
sweeping rewrite.

**Anti-pattern:** Leaves the structure as-is and just adds more nullable
columns for a third event kind, or proposes an unrelated full rewrite of
the model layer.

---

## 14. Domain events over cross-context callbacks

**Request:** "When an order ships, I need to send an email, log an
activity, and check for a reward — where does that go?"

**Correct:** Proposes the "collect and dispatch" pattern — `Order#ship!`
emits one event; three independent subscribers each handle one concern —
rather than three sequential `after_save` callbacks on `Order` that
directly call into unrelated models.

**Anti-pattern:** Adds three `after_save` callbacks on `Order`, each
reaching directly into `NotificationMailer`, `Activity`, and
`Rewards::Evaluator` — coupling `Order` to all three.

---

## 15. Response format completeness

**Request:** Any implementation task.

**Correct:** Final response follows the `SKILL.md` Response Format
section — summary, changed files, design decisions (including any
shameless-green-vs-abstraction call made), validation actually run, tests
added, risks/limitations honestly stated.

**Anti-pattern:** Claims tests pass without having run them, or omits
which validations could not be executed in the current environment.
