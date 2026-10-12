module Events
  class Vote < ApplicationRecord
    belongs_to :event, class_name: "Events::Event"

    validates :user_id, presence: true
    validates :event_id, uniqueness: { scope: :user_id, message: "already voted for this event" }
  end
end
