class ApplicationSubscriptions
  def self.handlers
    top_level_subscriptions
      .merge(Events.subscriptions)
      .merge(BillettoEventsIntegrator.subscriptions)
  end

  def self.top_level_subscriptions
    {}
  end
end
