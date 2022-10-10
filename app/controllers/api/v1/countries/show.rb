# frozen_string_literal: true

module API
  module V1
    module Countries
      class Show < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :countries do
          desc "List of all countries. Requires authentication.", entity: API::V1::Countries::Entities::IndexEntity
          get do
            result = {countries: Country.all.map{|c| {name: c.name, alpha2: c.alpha2}}}
            present result, with: API::V1::Countries::Entities::IndexEntity
          end
        end
      end      
    end
  end
end