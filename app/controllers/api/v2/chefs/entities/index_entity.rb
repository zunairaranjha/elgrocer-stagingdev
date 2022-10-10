# frozen_string_literal: true

module API
  module V2
    module Chefs
      module Entities
        class IndexEntity < API::V1::Chefs::Entities::ShowEntity

          def self.entity_name
            'chef_index'
          end

          expose :storyly_slug, documentation: { type: 'String', desc: 'Storyly Slug' }, format_with: :string
          expose :priority, documentation: { type: 'Integer', desc: 'Priority' }, format_with: :integer

        end
      end
    end
  end
end
