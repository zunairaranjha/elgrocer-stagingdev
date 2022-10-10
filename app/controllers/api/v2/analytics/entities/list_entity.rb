# frozen_string_literal: true

module API
  module V2
    module Analytics
      module Entities
        class ListEntity < API::V2::Analytics::Entities::ShowEntity
          expose :created_at, documentation: { type: 'DateTime', desc: 'Date, Time event create' }, format_with: :dateTime
        end
      end
    end
  end
end
