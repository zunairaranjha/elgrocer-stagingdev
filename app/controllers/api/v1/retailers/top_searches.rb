# frozen_string_literal: true

module API
  module V1
    module Retailers
      class TopSearches < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :retailers do
          desc "Returns top searches of retailer."
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer ID'
          end
          get '/top_searches' do
            Rails.cache.fetch("#{params[:retailer_id]}/#{I18n.locale}/top_searches", expires_in: 3.hours) do
              searches = Searchjoy::Search.where(retailer_id: params[:retailer_id],language: I18n.locale).where('created_at > ?', 30.days.ago).group(:query).order("count(query) desc").limit(20).pluck(:query)
              if searches && searches.count > 5
                searches
              else
                if I18n.locale == :ar
                  ['حليب', 'ماء', 'خبز', 'آيس كريم', 'موز', 'طماطم', 'قهوة', 'بيض', 'دجاج', 'جوز الهند', 'جبنة', 'بصل', 'ليمون', 'نسكافيه', 'أرز', 'تونة', 'خيار', 'شاي', 'محارم', 'زبدة', 'فشار', 'سكر']
                else
                  ['milk','water','bread','ice cream','banana','tomato','coffee','eggs','chicken','coconut','cheese','onion','lemon','nescafe','rice','tuna','cucumber','tea','tissue','butter','popcorn sugar']
                end
              end
            end
          end
        end
      end      
    end
  end
end