# frozen_string_literal: true

module API
  module V1
    module Products
      class ShopperElasticSearch < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :products do
          desc "Find product by provided input.", entity: API::V1::Products::Entities::ElasticSearchEntity
          params do
            requires :search_input, type: String, desc: 'Search input', documentation: { example: 'CocaCola' }
            requires :page, type: Integer, desc: "Page number", documentation: {example: 2}
            optional :retailer_id, type: Integer, desc: 'Retailer id', documentation: { example: 2 }
            optional :user_id, type: Integer, desc: 'Retailer id', documentation: { example: 2 }
            optional :brand_id, type: Integer, desc: "Brand ID", documentation: { example: 2 }
            optional :category_id, type: Integer, desc: "Category ID", documentation: { example: 2 }
            optional :subcategory_id, type: Integer, desc: "Sub Category ID", documentation: { example: 2 }
          end
      
          post '/shopper/elastic_search' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            ## if params[:retailer_id]
            ##   result = Shop.search_name(false, params[:search_input], params[:retailer_id]).page(params[:page])
            ## else
            ##   result = Shop.search_name(false, params[:search_input]).page(params[:page])
            ## end
            #
            #query = Shop.prepare_query_for_products(params[:search_input], params[:retailer_id], params[:brand_id], [params[:subcategory_id]])
            #query[:bool][:must].push({terms: {'categories.id': [params[:category_id]]}}) if params[:category_id].present?
            #product_ids = BrandSearchKeyword.where('keywords ilike ? and ? between date(start_date) and date(end_date)', "%#{params[:search_input]}%", Time.now.to_date).pluck(:product_ids)
            #if product_ids.present?
            #  product_ids = product_ids.to_s.scan(/\d+/)
            #  query[:bool][:should] = [{"constant_score": {"filter": {"terms": { "id": product_ids}}, boost: 500}}]
            #  # query[:bool][:should] = []
            #  # query[:bool][:should].push({ match: { "id": { query: [4481, 23865], boost: 1 }}})
            #end
            #result = Shop.search(query,{sort: ['_score', { product_rank: { order: :desc }}]}).page(params[:page])
            #
            #if params[:search_input].length>=3 # && result.total_count > 0
            #  save_params = {search_type: "Product", query: params[:search_input].strip, results_count: result.total_count, user_id: params[:user_id], retailer_id: params[:retailer_id],language: I18n.locale}
            #  Resque.enqueue(Shop, save_params)
            #  # Searchjoy::Search.create(search_type: "Product", query: params[:search_input].strip, results_count: result.total_count, user_id: params[:user_id], retailer_id: params[:retailer_id],language: I18n.locale )
            #end
            ##Searchjoy::Search.create(search_type: "#{index_name}", query: input,results_count: 12,user_id: 1)
            #product_ids.present? ? result.map { |obj| obj.merge(_source:{is_sponsored: product_ids.include?(obj[:_source][:id].to_s)}) } : result
            ##result
          end
      
          post '/shopper/search_suggesions' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            ## query = { bool: { must: [{ match: { name: params[:search_input] }}]}}
            ## query[:bool][:must].push({match: {retailer_id: params[:retailer_id].to_i }}) unless params[:retailer_id].blank?
            #query = Shop.prepare_query_for_products(params[:search_input], params[:retailer_id], nil, [])
            #extra = {
            #  aggs: {
            #    category_ids: { terms: { field: 'categories.id'} },
            #    subcategory_ids: { terms: { field: 'categories.children.id' } },
            #    brand_ids: { terms: { field: 'brand.id' } }
            #  }
            #}
            ## extra = {size: 0, aggs: { by_brand: { terms: { field: 'brand.id', size: 0 }, aggs: { by_top_hit: { top_hits: { size: 1000 } } } } },sort: { "brand.id": "asc" }}
            #result = Shop.search(query,extra)
            #
            #ids = result.aggregations[:subcategory_ids][:buckets].map {|b| b[:key]}
            #subCats = Category.where(id: ids).sort_by {|p| ids.index(p.id) }
            #ids = result.aggregations[:category_ids][:buckets].map {|b| b[:key]}
            #cats = Category.where(id: ids).sort_by {|p| ids.index(p.id) }
            #ids = result.aggregations[:brand_ids][:buckets].map {|b| b[:key]}
            #brands = Brand.where(id: ids).sort_by {|p| ids.index(p.id) }
            #
            #aggs = {aggs: result.aggregations, categories: cats, subcategories: subCats, brands: brands}
            ## present aggs
            ## present subCats, with: API::V2::Categories::Entities::ShowEntity
            ## present cats, with: API::V2::Categories::Entities::ShowEntity
            ## present brands, with: API::V1::Brands::Entities::ShowEntity
            #present aggs, with: API::V1::Products::Entities::ShowAggregationEntity
          end
      
          post '/shopper/search_suggesions2' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            #query = { bool: { must: [ { match: { name: params[:search_input] }} ] } }
            #query[:bool][:must].push({match: {retailer_id: params[:retailer_id].to_i }}) unless params[:retailer_id].blank?
            #extra = {
            #  size: 0,
            #  aggs: {
            #    Categories: { terms: { field: 'categories.name'} },
            #    SubCategories: { terms: { field: 'categories.children.name' } },
            #    Brands: { terms: { field: 'brand.name' } }
            #  }
            #}
            ## extra = {size: 0, aggs: { by_brand: { terms: { field: 'brand.id', size: 0 }, aggs: { by_top_hit: { top_hits: { size: 1000 } } } } },sort: { "brand.id": "asc" }}
            #result = Shop.search(query, extra)
            #result.aggregations
          end
      
        end
      end
    end
  end
end