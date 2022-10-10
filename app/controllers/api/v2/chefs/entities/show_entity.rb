# frozen_string_literal: true

module API
  module V2
    module Chefs
      module Entities
        class ShowEntity < API::V1::Chefs::Entities::ShowEntity

          def self.entity_name
            'chef_entity'
          end

          unexpose :image_url
          unexpose :slug
          unexpose :description

        end
      end
    end
  end
end