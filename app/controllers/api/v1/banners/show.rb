
module API
  module V1
    module Banners
      class Show < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :banners do
          desc 'To show Banners'
      
          params do
            requires :retailer_ids, type: String, desc: 'Retailers Ids to Get Banners', documentation: {example: '16,178,201'}
            requires :limit, type: Integer, desc: 'Limit of banners', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of banners', documentation: { example: 10 }
            optional :banner_type, type: Integer, desc: 'Banner type', documentation: { example: 0 }
            # optional :subcategory_id, type: Integer, desc: "Subcategory ID", documentation: { example: 173 }
          end
      
          get '/show' do
            banners = Banner.joins(:banners_retailers).where(is_active: true)
            # banners = banners.joins(:banner_links)
            # banners = banners.joins("LEFT JOIN categories ON categories.id = banner_links.category_id AND categories.parent_id IS NULL")
            # banners = banners.joins("LEFT JOIN categories AS sub_categories ON sub_categories.id = banner_links.category_id AND sub_categories.parent_id IS NOT NULL")
            # banners = banners.joins("LEFT JOIN brands ON brands.id = banner_links.brand_id")
            banners = banners.where("? between date(start_date) and date(end_date)", Time.now.to_date)
            banners = banners.where(banners_retailers: {retailer_id: params[:retailer_ids].split(',')})
            # banners = banners.where('banner_links.category_id is null OR banner_links.category_id in (?)', RetailerCategory.joins(:category).where(retailer_id: params[:retailer_ids].split(",")).where(categories: {parent_id: nil}).select(:category_id).uniq)
            # banners = params[:subcategory_id].present? ? banners.where("banner_links.subcategory_id = #{params[:subcategory_id]}") : banners.where('banner_links.subcategory_id is null OR banner_links.subcategory_id in (?)', RetailerCategory.joins(:category).where(retailer_id: params[:retailer_ids].split(",")).where.not(categories: {parent_id: nil}).select(:category_id).uniq)
            if params[:banner_type]
              banners = [1,3].include?(params[:banner_type]) ? banners.where(banner_type: [params[:banner_type],0,4]) : banners.where(banner_type: [params[:banner_type],0])
            else
              banners = banners.where(banner_type: [0,3,4])
            end
            banners = banners.select("banners.*, ARRAY_AGG(banners_retailers.retailer_id) AS banner_store_ids")
            banners = banners.order(:group, :priority).order(:id)
            banners = banners.group("banners.id")
      
            banners_cached = Rails.cache.fetch([params.merge(banners_updated_at: "#{banners.maximum('banners.updated_at')}").except(:ip_address),__method__], expires_in: 15.minutes) do
              banners = banners.includes(banner_links: [:category, :subcategory, :brand])
              banners.to_a
            end
            present banners_cached, with: API::V1::Banners::Entities::ShowEntity
          end
        end
      end
      
    end
  end
end