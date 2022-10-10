# frozen_string_literal: true

module API
  module V1
    module Products
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::Products::AvailableQuantity
        mount API::V1::Products::BarcodeSearch
        mount API::V1::Products::Show
        mount API::V1::Products::Index
        mount API::V1::Products::UpdateImage
        mount API::V1::Products::Update
        mount API::V1::Products::AddToShop
        mount API::V1::Products::ElasticSearch
        mount API::V1::Products::ShopperElasticSearch
        mount API::V1::Products::RemoveFromShop
        mount API::V1::Products::SubstitutionSearch
        mount API::V1::Products::UpdateShop
        mount API::V1::Products::ShowDetail
        mount API::V1::Products::Catalog
        mount API::V1::Products::TopSelling
        mount API::V1::Products::Featured
        mount API::V1::Products::CarouselProducts
        mount API::V1::Products::Promotional
        mount API::V1::Products::BrandProduct
      end
    end
  end
end
