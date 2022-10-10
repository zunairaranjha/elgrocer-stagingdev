module API::V1::Concerns::SharedParams
  extend Grape::API::Helpers

  params :categories_tree do
    requires :limit, type: Integer, desc: 'Limit of categories', documentation: { example: 20 }
    requires :offset, type: Integer, desc: 'Offset of categories', documentation: { example: 10 }
    optional :parent_id, type: Integer, desc: 'Id of category parent', documentation: {example: 1}
    optional :retailer_id, type: Integer, desc: 'Id of retailer', documentation: {example: 1}
    optional :latitude, type: Float, desc: 'ShopperAddress latitude', documentation: {example: 1}
    optional :longitude, type: Float, desc: 'ShopperAddress longitude', documentation: {example: 1}
  end
end
