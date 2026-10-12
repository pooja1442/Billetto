module Events
  class EventIngested < RubyEventStore::Event
    SCHEMA = {
      external_id: String,
      title: String,
      description: String,
      image_url: String,
      starts_at: String,
      ends_at: String,
      url: String,
      slug: String,
      status: String,
    }.freeze
  end

  class EventVoted < RubyEventStore::Event
    SCHEMA = {
      event_id: Integer,
      external_id: String,
      user_id: String,
    }.freeze
  end

  def self.subscriptions
    [].each_with_object({}) do |handler, hash|
      handler.build_subscriptions.each do |event_class, handlers|
        hash[event_class] ||= []
        hash[event_class].concat(handlers)
      end
    end
  end
end
