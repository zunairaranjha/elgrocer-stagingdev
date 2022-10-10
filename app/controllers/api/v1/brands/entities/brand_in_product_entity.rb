module API
  module V1
    module Brands
      module Entities
        class BrandInProductEntity < API::V1::Brands::Entities::ShowEntity
          unexpose :photo_url
          unexpose :logo1_url
          unexpose :logo2_url
        end
      end
    end
  end
end
