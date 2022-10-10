# frozen_string_literal: true

module API
  module V1
    module Products
      class SubstitutionSearch < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :products do
          desc "Find product by provided input.", entity: API::V1::Products::Entities::ElasticSearchEntity
          params do
            requires :search_input, type: String, desc: 'Search input', documentation: { example: 'CocaCola' }
            requires :retailer_id, type: Integer, desc: "Retailer ID", documentation: { example: 2 }
            optional :brand_id, type: Integer, desc: "Brand ID", documentation: { example: 2 }
            optional :product_id, type: Integer, desc: "Product ID to exclude from search results", documentation: { example: 2 }
            optional :product_brand_name, type: String, desc: "brand name", documentation: { example: 'al ain' }
            optional :subcategory_id, type: Integer, desc: "Category ID", documentation: { example: 2 }
            optional :product_subcategory_name, type: String, desc: "SubCategory name", documentation: { example: 'Juices' }
            optional :size_unit, type: String, desc: "product size unit", documentation: { example: '1L' }
            optional :price_full, type: String, desc: "Product Price", documentation: { example: '6.5' }
            #optional :flavour, type: String, desc: "flavour", documentation: { example:  }
            optional :limit, type: Integer, desc: 'Limit of categories', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of categories', documentation: { example: 10 }
            optional :is_food, type: Boolean, desc: 'Food category', documentation: { example: true }
          end
      
          post '/substitution_search' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            ## result = Shop.search_products(params[:search_input], params[:retailer_id], nil, [], 100, 0)
            #category = Category.where("name ilike ? or id = ?", params[:product_subcategory_name], params[:subcategory_id]).first
            #if category && (sPreference = SubstitutionPreference.find_by(category: category)).present?
            #  query = Shop.prepare_query_for_products(params[:search_input], params[:retailer_id], nil, [category.id], sPreference.min_match, 'or')
            #  # query[:bool][:must].push({term: {'categories.children.name': params[:subcategory_name]}}) if params[:subcategory_name].present?
            #  #query[:bool][:must_not] = [{term:{id: params[:product_id]}}] if params[:product_id].to_i > 0
            #  query[:bool][:must_not].push({term:{id: params[:product_id]}}) if params[:product_id].to_i > 0
            #  query[:bool][:should] = []
            #  query[:bool][:should].push({ match: { "brand.id": { query: params[:brand_id], boost: sPreference.brand_priority }}}) if params[:brand_id].to_i > 0 && sPreference.brand_priority.to_i != 0
            #  query[:bool][:should].push({ match: { "brand_name": { query: params[:product_brand_name], boost: sPreference.brand_priority }}}) if params[:product_brand_name].present? && sPreference.brand_priority.to_i != 0
            #  query[:bool][:should].push({ match: { "size_unit": { query: params[:size_unit], boost: sPreference.size_priority }}}) if params[:size_unit].present? && sPreference.size_priority.to_i != 0
            #  query[:bool][:should].push({ match: { "price.price_full": { query: params[:price_full], boost: sPreference.price_priority }}}) if params[:price_full].present? && sPreference.price_priority.to_i != 0
            #  result = Shop.search(query,{size: params[:limit] || 10, from: params[:offset] || 0, sort: ['_score', { product_rank: { order: :desc }}]})
            #else
            #  # result = Shop.search_products(params[:search_input], params[:retailer_id], params[:brand_id], [params[:subcategory_id]], params[:limit] || 100, params[:offset], "or")
            #  query = Shop.prepare_query_for_products(params[:search_input], params[:retailer_id], params[:brand_id], [params[:subcategory_id]], "50", "or")
            #  result = Shop.search(query, {size: params[:limit] || 10, from: params[:offset] || 0, sort: ['_score', { product_rank: { order: :desc }}] })
            #end
            #present result, with: API::V1::Products::Entities::ElasticSearchEntity
          end
      
          post '/alternate_search' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            #query = Shop.prepare_query_for_products(params[:search_input], params[:retailer_id], nil, [], "30", 'or')
            #query[:bool][:must].push({terms: {'categories.id': Category.where(is_food: true, parent_id: nil).ids}}) if params[:is_food] == "true"
            ##query[:bool][:must_not] = [{term:{id: params[:product_id]}}] if params[:product_id].to_i > 0
            #query[:bool][:must_not].push({term:{id: params[:product_id]}}) if params[:product_id].to_i > 0
            #query[:bool][:should] = []
            #query[:bool][:should].push({ match: { "brand.id": { query: params[:brand_id], boost: 2 }}}) if params[:brand_id].to_i > 0
            #query[:bool][:should].push({ match: { "categories.children.id": { query: params[:subcategory_id], boost: 2 }}}) if params[:subcategory_id].to_i > 0
            #query[:bool][:should].push({ match: { "brand_name": { query: params[:product_brand_name], boost: 2 }}}) if params[:product_brand_name].present?
            #query[:bool][:should].push({ match: { "size_unit": { query: params[:size_unit], boost: 2 }}}) if params[:size_unit].present?
            #query[:bool][:should].push({ match: { "price.price_full": { query: params[:price_full], boost: 2 }}}) if params[:price_full].present?
            #query[:bool][:must][0][:multi_match][:fuzziness] = "#{(Redis.current.get :alt_es_fuzziness) || 5}"
            #query[:bool][:must][0][:multi_match][:minimum_should_match] = "#{(Redis.current.get :alt_es_min_match) || 30}%"
            #result = Shop.search(query,{size: params[:limit] || 10, from:params[:offset] || 0, sort: ['_score', { product_rank: { order: :desc }}]})
            #result
          end
        end
      end      
    end
  end
end