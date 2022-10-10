module API
  module V1
    module Recipes
      class ProductElasticSearch < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :recipes do
          desc "Find product by provided input. Requires authentication.", entity: API::V1::Products::Entities::ElasticSearchEntity
          params do
            requires :search_input, type: String, desc: 'Search input', documentation: { example: 'CocaCola' }
            requires :page, type: Integer, desc: "Page number", documentation: { example: 2 }
          end
      
          post 'product_elastic_search' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
              #query = Shop.prepare_query_for_products(params[:search_input], nil, nil, [])
              #category_ids = Category.where("name like ?","%Promotion%").ids
              #query[:bool][:must_not].push({terms: {'categories.children.id': category_ids}})
              #extra = {
              #  "size": 0,
              #  "aggs": {
              #    "products": { "terms": { "field": "id"},
              #      "aggs": {
              #        "top_docs": {
              #          "top_hits": {
              #            "sort": [
              #              "_score", {
              #                "product_rank": {
              #                  "order": "desc"
              #                }
              #              }
              #            ],
              #            "size": 1
              #          }
              #        }
              #      }
              #    }
              #  }
              #}
              #result = Shop.search(query,extra).page(params[:page])
              #result = result.aggregations[:products][:buckets].map {|b| b[:top_docs][:hits][:hits].first}
              #present result, with: API::V1::Products::Entities::ElasticSearchEntity
          end
        end
      end
    end
  end
end