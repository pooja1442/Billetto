module Events
  class VoteForEvent
    include Command::Executable

    attribute :event_id, :integer
    attribute :user_id, :string

    validates :event_id, :user_id, presence: true

    def call
      raise ActiveModel::ValidationError.new(self) unless valid?

      event = Events::Event.find(event_id)
      vote  = event.votes.create!(user_id: user_id)

      event_store.publish(
        Events::EventVoted.new(data: {
          event_id:    event.id,
          external_id: event.external_id,
          user_id:     user_id,
        }),
        stream_name:  "Event$#{event.external_id}",
        expected_version: :any
      )
      event_store.link(
        [event_store.read.stream("Event$#{event.external_id}").last.event_id],
        stream_name: "User$#{user_id}"
      )

      vote
    rescue ActiveRecord::RecordNotUnique
      raise ActiveRecord::RecordInvalid, "You have already voted for this event"
    end
  end
end
