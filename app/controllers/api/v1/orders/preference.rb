# frozen_string_literal: true

module API
  module V1
    module Orders
      class Preference < Grape::API
        version 'v1', using: :path
        format :json

        resource :orders do
          desc 'lists Substitution Preference here!'

          get '/substitution/preferences' do
            result = JSON(SystemConfiguration.find_by(key: 'substitution_preference').value).to_a
            present result, with: API::V1::Orders::Entities::SubstitutionPreferenceEntity
          end
        end
      end
    end
  end
end
