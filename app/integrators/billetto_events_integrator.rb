module BillettoEventsIntegrator
  class IngestEventsWhenFetchedFromApi
    include Handler::Sync

    subscribes_to BillettoApi::EventsFetched

    def call(fact)
      fact.data.fetch(:events).each do |event_attrs|
        command_bus.call(
          Events::IngestEvent.new(**event_attrs.transform_keys(&:to_sym))
        )
      rescue ActiveModel::ValidationError => e
        Rails.logger.warn("Skipping invalid event (#{event_attrs[:external_id]}): #{e.message}")
      end
    end
  end

  def self.subscriptions
    [IngestEventsWhenFetchedFromApi].each_with_object({}) do |handler, hash|
      handler.build_subscriptions.each do |event_class, handlers|
        hash[event_class] ||= []
        hash[event_class].concat(handlers)
      end
    end
  end
end
