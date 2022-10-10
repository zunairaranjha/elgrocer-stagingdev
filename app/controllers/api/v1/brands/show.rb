# frozen_string_literal: true

module API
  module V1
    module Brands
      class Show < Grape::API
        version 'v1', using: :path
        format :json

        resource :brands do
          include TokenAuthenticable

          desc 'List of all brands. Requires authentication.', entity: API::V1::Brands::Entities::IndexEntity

          params do
            requires :limit, type: Integer, desc: 'Limit of categories', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of categories', documentation: { example: 10 }
          end

          get do
            is_next = false
            if params['limit'] + params['offset'] < Brand.count
              is_next = true
            end
            result = { :next => is_next, brands: Brand.limit(params['limit']).offset(params['offset']).order(:name) }
            present result, with: API::V1::Brands::Entities::IndexEntity
          end
        end

        resource :brands do
          desc 'List of all brands. Requires authentication.'
          params do
            requires :id, desc: 'Id of brand', documentation: { example: 20 }
          end

          get '/show' do
            result = params[:id][/\p{L}/] ? Brand.find_by(slug: params[:id]) : Brand.find_by(id: params[:id])
            error!(CustomErrors.instance.brand_not_found, 421) unless result
            API::V1::Brands::Entities::ShowEntity.represent result, except: [:logo1_url, :logo2_url], root: false
          end
        end
      end
    end
  end
end
