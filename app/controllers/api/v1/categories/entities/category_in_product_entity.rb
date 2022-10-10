# frozen_string_literal: true

module API
  module V1
    module Categories
      module Entities
        class CategoryInProductEntity < API::V1::Products::Entities::ShowNameEntity

          unexpose :image_url

        end
      end
    end
  end
end
