module API
  module V1
    module Banners
      class Index < Grape::API
        version 'v1', using: :path
        format :json

        resource :banners do
          desc "List of active banners.", entity: API::V1::Banners::Entities::ShowEntity

          params do
            requires :limit, type: Integer, desc: 'Limit of banners', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of banners', documentation: { example: 10 }
            requires :retailer_id, desc: 'Retailer ID', documentation: { example: 10 }
            optional :search_input, type: String, desc: 'Search input', documentation: { example: 'Milk' }
            optional :banner_type, type: Integer, desc: 'Banner type', documentation: { example: 0 }
            optional :is_show, type: Boolean, desc: "Show banners", documentation: { example: true }
            optional :subcategory_id, type: Integer, desc: "Subcategory ID", documentation: { example: 173 }
          end

          get do
            if params[:is_show]
              retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
              banners = Banner.joins(:banners_retailers).where(is_active: true).eager_load(banner_links: [:category, :subcategory, :brand])
              # banners = banners.joins("LEFT join banner_links on banners.id = banner_links.banner_id").includes(banner_links: [:category, :subcategory, :brand]).group('banners.id')
              banners = banners.where("? between date(start_date) and date(end_date)", Time.now.to_date)
              banners = banners.where(banners_retailers: { retailer_id: retailer.id })
              banners = banners.where('banner_links.category_id is null OR banner_links.category_id in (?)', retailer.rcategories.where(parent_id: nil).ids.uniq)
              banners = params[:subcategory_id].present? ? banners.where("banner_links.subcategory_id = #{params[:subcategory_id]}") : banners.where('banner_links.subcategory_id is null OR banner_links.subcategory_id in (?)', retailer.rcategories.where.not(parent_id: nil).ids.uniq)
              # banners = banners.where('banner_links.brand_id is null OR banner_links.brand_id in (?)', retailer.brand_ids_uniq)
              # banners = banners.limit(params['limit']).offset(params['offset'])
              if params[:banner_type]
                banners = [1, 3].include?(params[:banner_type]) ? banners.where(banner_type: [params[:banner_type], 0, 4]) : banners.where(banner_type: [params[:banner_type], 0])
              else
                banners = banners.where(banner_type: [0, 1, 4])
              end
              if params[:search_input]
                # search_input = params[:search_input].split(" ")
                # search_input.map! { |word| "keywords ILIKE '%#{word.gsub(/'/) { |x| "'" + x }}%'" }
                # search_input = search_input.join(" or ")
                # banners = banners.where(search_input)
                banners = banners.where("keywords ~ '\\y#{params[:search_input].downcase.gsub("'", "''")}\\y'")
                banners = banners.order('RANDOM()')
              else
                banners = banners.order(:group, :priority).order(:id).order('banner_links.priority')
              end

              banners_cached = Rails.cache.fetch([params.merge(banners_updated_at: "#{banners.maximum('banners.updated_at')}").except(:ip_address), __method__], expires_in: 15.minutes) do
                banners.to_a
              end
              banners_cached = banners_cached.shuffle if params[:search_input]
              present banners_cached, with: API::V1::Banners::Entities::ShowEntity
            else
              banners_cached = []
              present banners_cached, with: API::V1::Banners::Entities::ShowEntity
            end
          end
        end
      end
    end
  end
end