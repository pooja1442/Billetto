module BillettoApi
  class FetchPublicEvents
    include Command::Executable

    attribute :limit, :integer, default: 100

    def call
      adapter = Rails.configuration.billetto_api
      response = adapter.fetch_public_events(limit: limit)

      raw_events = response.fetch(:data, [])
      mapped_events = raw_events.map { |e| map_event(e) }

      event_store.publish(
        BillettoApi::EventsFetched.new(data: {
          events: mapped_events,
          total: mapped_events.size
        }),
        stream_name: "BillettoApi$PublicEvents"
      )

      mapped_events
    end

    private

    def map_event(raw)
      {
        external_id: raw[:id]&.to_s,
        title: raw[:title].to_s,
        description: raw[:description].to_s,
        image_url: raw[:image_link],
        starts_at: raw[:startdate],
        ends_at: raw[:enddate],
        url: raw[:url],
        slug: raw[:slug],
        status: raw[:state],
      }
    end
  end
end
