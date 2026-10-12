class VotesController < ApplicationController
  before_action :require_clerk_session!

  def create
    @event = Events::Event.includes(:votes).find(params[:event_id])
    command_bus.call(
      Events::VoteForEvent.new(
        event_id: @event.id,
        user_id:  clerk.user_id
      )
    )
    @event.votes.reload
    @voted = true
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to events_path, notice: "Your vote has been recorded!" }
    end
  rescue ActiveRecord::RecordInvalid
    @event ||= Events::Event.includes(:votes).find(params[:event_id])
    @voted = true
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to events_path, alert: "You have already voted for this event." }
    end
  rescue ActiveModel::ValidationError => e
    redirect_to events_path, alert: e.message
  end

  private

  def command_bus
    Rails.configuration.command_bus
  end
end
