# frozen_string_literal: true

module API
  module V1
    module Locations
      module Entities
        class ShowEntity < API::BaseEntity
          def self.entity_name
            'show_location'
          end
          expose :name, documentation: { type: 'String', desc: "Location name" }, format_with: :string
          expose :id, documentation: { type: 'Integer', desc: "Location id" }, format_with: :integer
          expose :is_covered, documentation: { type: 'Bool', desc: "Describes if there is at least one shop in the location", format_with: :bool }
          expose :active, documentation: { type: 'Bool', desc: "Is Active", format_with: :bool }
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :seo_data, documentation: {type: 'String', desc: "SEO Data"}, format_with: :string, if: Proc.new { |obj| options[:web] }
          expose :city, using: API::V1::Cities::Entities::ShowEntity, documentation: {type: 'show_city', is_array: true }
        
          private
        
          def is_covered
            object.try(:covered) || object.try(:is_covered)
          end
        end        
      end
    end
  end
end