module API
  module V1
    module Campaigns
      class Index < Grape::API
        version 'v1', using: :path
        format :json

        resource :campaigns do
          desc 'To get Campaigns'

          params do
            requires :location, type: Integer, desc: 'Location Id', documentation: { example: 1 }
            optional :retailer_ids, type: String, desc: 'Retailer Ids', documentation: { example: '16,178' }
            optional :store_type_ids, type: String, desc: 'Store Type Ids', documentation: { example: '1,7' }
            optional :retailer_group_ids, type: String, desc: 'Retailer Group Ids', documentation: { example: '1,3' }
            optional :category_id, type: Integer, desc: 'Category Id', documentation: { example: 90 }
            optional :subcategory_id, type: Integer, desc: 'Subcategory Id', documentation: { example: 100 }
            optional :brand_id, type: Integer, desc: 'Brand Id', documentation: { example: 899 }
            optional :search_input, type: String, desc: 'Search keywords', documentation: { example: 'milk' }
          end

          get do
            error!(CustomErrors.instance.params_missing, 421) unless params[:retailer_ids].present?
            store_type_ids = RetailerStoreType.distinct.where("retailer_id in (#{params[:retailer_ids]})").pluck(:store_type_id).join(',')
            retailer_group_ids = Retailer.distinct.where("id in (#{params[:retailer_ids]})").where.not(retailer_group_id: nil).pluck(:retailer_group_id).join(',')
            campaigns = Campaign.includes(:c_brands, :c_categories, :c_subcategories).where('? BETWEEN start_time AND end_time', Time.now.utc)
            campaigns = campaigns.where('? = ANY(locations)', params[:location])
            campaigns = campaigns.where.not("'{#{params[:retailer_ids]}}'::INT[] && exclude_retailer_ids") unless params[:retailer_ids].split(',').length > 1
            campaigns = campaigns.order(:priority)
            # campaigns = campaigns.where("'{#{store_type_ids}}'::INT[] && store_type_ids")
            # campaigns = campaigns.where("'{#{retailer_group_ids}}'::INT[] && retailer_group_ids")
            campaigns = campaigns.where('? = ANY(category_ids)', params[:category_id]) if params[:category_id]
            campaigns = campaigns.where('? = ANY(subcategory_ids)', params[:subcategory_id]) if params[:subcategory_id]
            campaigns = campaigns.where('? = ANY(brand_ids)', params[:brand_id]) if params[:brand_id]
            campaigns = campaigns.where('? = ANY(keywords)', params[:search_input].downcase.gsub("'", "''")) if params[:search_input]
            campaigns = campaigns.where("'{#{params[:retailer_ids]}}'::INT[] && retailer_ids OR '{#{store_type_ids}}'::INT[] && store_type_ids OR '{#{retailer_group_ids}}'::INT[] && retailer_group_ids")
            present campaigns, with: API::V1::Campaigns::Entities::IndexEntity, web: request.headers['Referer']
          end
        end
      end
    end
  end
end

