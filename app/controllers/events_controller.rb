class EventsController < ApplicationController
  def index
    @events = Events::Event.includes(:votes).order(starts_at: :asc)
    @user_voted_ids = clerk.user_id \
      ? Events::Vote.where(user_id: clerk.user_id).pluck(:event_id).to_set
      : Set.new
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
