# frozen_string_literal: true

module API
  module V2
    module Analytics
      module Entities
        class ShowEntity < API::BaseEntity
          root 'analytics', 'analytic'

          def self.entity_name
            'show_analytic'
          end

          # expose :id, documentation: { type: 'Integer', desc: "ID of the analytic" }, format_with: :integer
          expose :event_id, documentation: { type: 'Integer', desc: 'ID of the event' }, format_with: :integer
          expose :event, documentation: { type: 'String', desc: 'Event' }, format_with: :string
          expose :created_at, documentation: { type: 'String', desc: 'Date, Time event create' }, format_with: :string
          # expose :updated_at, documentation: { type: 'String', desc: "Date, Time event update" }, format_with: :string
          # expose :owner_id, documentation: { type: "Integer", desc: 'Owner Id'}, format_with: :integer
          # expose :owner_type, documentation: { type: 'String', desc: "Owner Type" }, format_with: :string

          def event
            object.event.name
          end
        end
      end
    end
  end
end
