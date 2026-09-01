# Ruby/Rails Examples

Short, idiomatic examples illustrating the principles in `SKILL.md`. These
are reference shapes, not a library to copy verbatim — adapt names and
context to the project at hand.

## Shameless green, then flocking rules

Start concrete. Two similar-looking methods are fine until a third case
reveals the actual pattern:

```ruby
# Step 1 — shameless green: two reward checks, written plainly, some duplication
def check_books_read_reward(user)
  count = user.user_books.read.count
  Reward.where(trigger_type: "books_read").where("threshold <= ?", count).find_each do |reward|
    user.rewards.find_or_create_by!(reward:)
  end
end

def check_reviews_written_reward(user)
  count = user.reviews.count
  Reward.where(trigger_type: "reviews_written").where("threshold <= ?", count).find_each do |reward|
    user.rewards.find_or_create_by!(reward:)
  end
end

# Step 2 — a third trigger arrives; the pattern is now visible, extract it
class Rewards::Evaluator
  def self.call(user, trigger:)
    count = count_for(user, trigger)
    Reward.where(trigger_type: trigger).where("threshold <= ?", count).find_each do |reward|
      user.rewards.find_or_create_by!(reward:)
    end
  end

  def self.count_for(user, trigger)
    case trigger
    when "books_read" then user.user_books.read.count
    when "reviews_written" then user.reviews.count
    when "clubs_joined" then user.club_memberships.active.count
    end
  end
end
```

Extracting after the second occurrence, before the third, would have been
guessing at the shape. Waiting for the third is the Rule of Three in
practice.

---

## Duck typing over type checks

```ruby
# Avoid
def deliver(notification, channel)
  case channel
  when :in_app then InAppDelivery.new.deliver(notification)
  when :email then EmailDelivery.new.deliver(notification)
  end
end

# Prefer — caller doesn't inspect the channel, it just uses it
def deliver(notification, channel)
  channel.deliver(notification)
end

class InAppDelivery
  def deliver(notification) = NotificationLog.create!(notification.to_h)
end

class EmailDelivery
  def deliver(notification) = NotificationMailer.with(notification.to_h).deliver_now
end
```

---

## Domain events: state change vs. side effects

```ruby
class UserBook < ApplicationRecord
  include Eventable

  class AlreadyReadError < StandardError; end

  def finish_reading
    raise AlreadyReadError if read?
    update!(status: :read, finished_at: Time.current)
    emit(BookFinished.new(user_id:, book_id:))
  end
end

# subscriber, registered once at boot — not known to UserBook
ActiveSupport::Notifications.subscribe("book_finished") do |*, payload|
  Rewards::EvaluationJob.perform_later(payload[:user_id], trigger: "books_read")
  Activity.create!(user_id: payload[:user_id], activity_type: :book_finished, reference_id: payload[:book_id])
end
```

`UserBook#finish_reading` never learns that finishing a book awards
rewards or logs activity — both can change independently of it.

---

## Pure PORO, no ActiveRecord dependency

```ruby
class Sm2Scheduler
  MIN_EASE_FACTOR = 1.3

  Result = Data.define(:ease_factor, :interval_days, :repetitions, :next_review_at)

  def self.reschedule(card, quality:)
    if quality < 3
      Result.new(ease_factor: card.ease_factor, interval_days: 1, repetitions: 0,
                  next_review_at: 1.day.from_now)
    else
      ease_factor = [card.ease_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)), MIN_EASE_FACTOR].max
      interval_days = next_interval(card.interval_days, card.repetitions, ease_factor)
      Result.new(ease_factor:, interval_days:, repetitions: card.repetitions + 1,
                  next_review_at: interval_days.days.from_now)
    end
  end

  def self.next_interval(previous_interval, repetitions, ease_factor)
    case repetitions
    when 0 then 1
    when 1 then 6
    else (previous_interval * ease_factor).round
    end
  end
  private_class_method :next_interval
end
```

Testable with a plain `Data.define` struct — no database, no Rails boot
required (see `references/testing.md`).

---

## Guard-clause state transitions

```ruby
class Session < ApplicationRecord
  class InvalidTransitionError < StandardError; end

  enum :status, { in_progress: 0, paused: 1, completed: 2, abandoned: 3 }

  def pause
    ensure_status!(:in_progress, action: "pause")
    update!(status: :paused, paused_at: Time.current)
  end

  def resume
    ensure_status!(:paused, action: "resume")
    total_paused_seconds_will_change = Time.current - paused_at
    update!(status: :in_progress, paused_at: nil,
            total_paused_seconds: total_paused_seconds + total_paused_seconds_will_change.to_i)
  end

  private

  def ensure_status!(expected, action:)
    return if status.to_sym == expected

    raise InvalidTransitionError, "cannot #{action} a session in status '#{status}'"
  end
end
```

One private guard method, reused by every transition, instead of a gem.

---

## Controller: thin action, ownership check, strong params

```ruby
class UserBooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_book, only: %i[update destroy]

  def create
    user_book = current_user.user_books.create!(user_book_params)
    redirect_to user_book, notice: t(".success")
  end

  def update
    @user_book.update!(user_book_params)
    redirect_to @user_book, notice: t(".success")
  end

  private

  def set_user_book
    @user_book = current_user.user_books.find(params[:id]) # scoped to current_user — ownership by construction
  end

  def user_book_params
    params.require(:user_book).permit(:status, :rating, :is_favorite, :notes, :current_page)
  end
end
```

Scoping `find` through `current_user.user_books` makes the ownership check
implicit and impossible to forget — a bare `UserBook.find(params[:id])`
followed by a manual comparison is one refactor away from a missing check.

---

## Api::V1 counterpart — same model call, different rendering

```ruby
module Api
  module V1
    class UserBooksController < BaseController
      def create
        user_book = current_user.user_books.create!(user_book_params)
        render json: user_book, status: :created
      end

      private

      def user_book_params
        params.require(:user_book).permit(:status, :rating, :is_favorite, :notes, :current_page)
      end
    end
  end
end
```

Identical domain call (`current_user.user_books.create!`) to the Hotwire
controller above — only the response format differs, per
`references/architecture.md`.

---

## Turbo Stream response

```erb
<%# app/views/clubs/messages/create.turbo_stream.erb %>
<%= turbo_stream.append "club_messages", partial: "clubs/messages/message", locals: { message: @message } %>
<%= turbo_stream.replace "club_message_form", partial: "clubs/messages/form", locals: { club: @club, message: Club::Message.new } %>
```

```ruby
class Clubs::MessagesController < ApplicationController
  def create
    @message = @club.messages.create!(message_params.merge(user: current_user))
    # Turbo Stream template above renders automatically for the requesting client;
    # broadcast to everyone else's open page:
    @message.broadcast_append_to @club, target: "club_messages", partial: "clubs/messages/message", locals: { message: @message }
  end
end
```

---

## Stimulus controller (client-only behavior)

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { remainingSeconds: Number }
  static targets = ["display"]

  connect() {
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    this.remainingSecondsValue -= 1
    this.displayTarget.textContent = this.formatted(this.remainingSecondsValue)
  }

  formatted(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    return `${minutes}:${String(seconds).padStart(2, "0")}`
  }
}
```

Purely presentational — the server, not this controller, decides the
session's actual elapsed/target time on pause/finish.

---

## Shared examples for a duck-typed interface

```ruby
RSpec.shared_examples "a notification channel" do
  it "responds to #deliver with a notification" do
    expect(subject).to respond_to(:deliver)
  end
end

RSpec.describe InAppDelivery do
  it_behaves_like "a notification channel"
end

RSpec.describe EmailDelivery do
  it_behaves_like "a notification channel"
end
```

---

## Avoiding N+1 queries

```ruby
# Vulnerable — one query per club to fetch its owner
@clubs = current_user.clubs

# In the view: club.owner.name  → N+1

# Fixed
@clubs = current_user.clubs.includes(:owner)
```

Run `bullet` (or check `SELECT` counts in a request spec) whenever a view
renders a collection with an association — catching this in review is
cheaper than catching it in production.
