module Events
  class Event < ApplicationRecord
    include EventStoreInjector

    self.table_name = "events"

    has_many :votes, class_name: "Events::Vote", foreign_key: :event_id, dependent: :destroy

    validates :external_id, presence: true, uniqueness: true
    validates :title, presence: true

    def self.ingest!(attributes)
      find_or_initialize_by(external_id: attributes[:external_id]).tap do |record|
        record.assign_attributes(attributes)
        record.save!
      end
    end
  end
end
