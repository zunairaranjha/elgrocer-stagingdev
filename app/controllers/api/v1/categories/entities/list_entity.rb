# frozen_string_literal: true

module API
  module V1
    module Categories
      module Entities
        class ListEntity < API::V2::Categories::Entities::ShowEntity
          unexpose :logo_url
          expose :colored_img_url, documentation: { type: 'String', desc: 'Colored Image Url' }, format_with: :string
        end
      end
    end
  end
end
