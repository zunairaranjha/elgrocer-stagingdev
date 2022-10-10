module API
  module V1
    module Screens
      module Entities
        class IndexEntity < API::BaseEntity
          def self.entity_name
            'index_screens'
          end

          expose :id, documentation: { type: 'Integer', desc: "Id of the screen" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Name of the Screen" }, format_with: :string
          expose :priority, documentation: { type: 'Integer', desc: "Priority f the Screen" }, format_with: :integer
          expose :group, documentation: { type: 'Integer', desc: "Group Number" }, format_with: :integer
          expose :photo_url, as: :image_url, documentation: { type: 'String', desc: "Photo url" }, format_with: :string
          expose :photo_ar_url, as: :image_ar_url, documentation: { type: 'String', desc: "Photo_ar url" }, format_with: :string
          expose :banner_photo_url, as: :banner_image_url, documentation: { type: 'String', desc: "Photo url" }, format_with: :string
          expose :banner_photo_ar_url, as: :banner_image_ar_url, documentation: { type: 'String', desc: "Photo_ar url" }, format_with: :string
          expose :retailer_ids, documentation: { type: 'store_ids', desc: "Retailer ids", is_array: true }
          expose :locations, documentation: { type: 'Array', desc: 'Array of locations', is_array: true }
          expose :store_types, documentation: { type: 'Array', desc: "Store Types", is_array: true }
          expose :retailer_groups, documentation: { type: 'Array', desc: 'Retailer Groups', is_array: true }

          private

          # def retailer_ids
          #   object.try("screen_store_ids")
          # end

        end
      end
    end
  end
end