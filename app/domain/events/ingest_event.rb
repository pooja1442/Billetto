module Events
  class IngestEvent
    include Command::Executable

    attribute :external_id, :string
    attribute :title, :string
    attribute :description, :string
    attribute :image_url, :string
    attribute :starts_at, :string
    attribute :ends_at, :string
    attribute :url, :string
    attribute :slug, :string
    attribute :status, :string

    validates :external_id, :title, presence: true

    def call
      raise ActiveModel::ValidationError.new(self) unless valid?

      event = Events::Event.ingest!(event_attributes)

      event_store.publish(
        Events::EventIngested.new(data: event_attributes),
        stream_name: "Event$#{event.external_id}"
      )

      event
    end

    private

    def event_attributes
      {
        external_id: external_id,
        title: title,
        description: description,
        image_url: image_url,
        starts_at: starts_at,
        ends_at: ends_at,
        url: url,
        slug: slug,
        status: status,
      }
    end
  end
end
