class EventsController < ApplicationController
  def index
    @events = Events::Event.order(starts_at: :asc)
  end

  def sync
    command_bus.call(BillettoApi::FetchPublicEvents.new)
    redirect_to events_path, notice: "Events synced successfully."
  rescue BillettoApi::Error => e
    redirect_to events_path, alert: "Failed to sync events: #{e.message}"
  end

  private

  def command_bus
    Rails.configuration.command_bus
  end
end
