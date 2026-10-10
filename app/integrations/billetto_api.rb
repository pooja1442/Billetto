module BillettoApi
  Error = Class.new(StandardError)
  ConnectionError = Class.new(Error)
  ApiError = Class.new(Error)
  ValidationError = Class.new(Error)

  class EventsFetched < RubyEventStore::Event
    SCHEMA = {
      events: Array,
      total: Integer,
      page: Integer,
    }.freeze
  end
end
