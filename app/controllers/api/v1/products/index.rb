module API
  module V1
    module Products
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :products do
          desc "List of all products in base or only in my shop. Requires authentication.", entity: API::V1::Products::Entities::IndexEntity
          params do
            requires :only_mine, type: Boolean, desc: 'Products only in my shop', documentation: { example: true }
            requires :retailer_id, type: Integer, desc: 'Retailer id', documentation: { example: 6 }
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            # optional :search_input, type: String, desc: 'Optional input for search filter', documentation: { example: 'CocaCola'}
            optional :is_published, type: Boolean, desc: 'published Products in my shop ', documentation: { example: false }
            optional :is_available, type: Boolean, desc: 'Products only in my shop', documentation: { example: false }
          end
          get do
            # if params[:only_mine]
            #   products = current_retailer.products.order(created_at: :desc).limit(params['limit']).offset(params['offset'])
            #   products = products.joins(:shops).where("shops.is_published=#{params[:is_published]}") unless params[:is_published].nil?
            #   products = products.joins(:shops).where("shops.is_available=#{params[:is_available]}") unless params[:is_available].nil?
      
            #   result = {products: products.map{|p| {retailer_id: current_retailer.id, product: p}}}
            #   present result, with: API::V1::Products::Entities::IndexEntity, retailer_id: current_retailer.id
            # else
            #   products = Product.order(created_at: :desc).limit(params['limit']).offset(params['offset'])
            #   products = products.joins(:shops).where("shops.is_published=#{params[:is_published]}") unless params[:is_published].nil?
            #   products = products.joins(:shops).where("shops.is_available=#{params[:is_available]}") unless params[:is_available].nil?
            #   result = {products: products.map{|p| {retailer_id: params[:retailer_id], product: p}}}
            #   present result, with: API::V1::Products::Entities::IndexEntity
            # end
            if params[:only_mine]
              products = current_retailer.products
            else
              products = Product.unscoped
              products = products.joins("left outer join shops on shops.product_id = products.id and shops.retailer_id = #{params[:retailer_id]}")
            end
            products = products.order(created_at: :desc).eager_load(:subcategories, :categories, :brand).limit(params['limit']).offset(params['offset'])
            # products = products.select('products.*,shops.id shop_id,shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.retailer_id') #if params[:retailer_id]
            # products = products.joins("AND shops.retailer_id = #{params[:retailer_id]}")
            # products = products.joins("INNER JOIN shops ON shops.product_id = products.id") if params[:only_mine] || params.has_key?(:is_published) || params.has_key?(:is_available)
            
            products = products.where("shops.retailer_id = #{params[:retailer_id]}") if params[:only_mine]
            products = products.where("shops.is_published=#{params[:is_published]}") unless params[:is_published].nil?
            products = products.where("shops.is_available=#{params[:is_available]}") unless params[:is_available].nil?
            # result = {products: products.map{|p| {retailer_id: params[:retailer_id], product: p}}}
            # present result, with: API::V1::Products::Entities::IndexEntity
            present products, with: API::V1::Products::Entities::ShowEntity, retailer: current_retailer
          end
        end
      end      
    end
  end
end