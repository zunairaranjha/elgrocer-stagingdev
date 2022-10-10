module API
	module V1
	  module Shoppers
		class DeletionReasons < Grape::API
		  version 'v1', using: :path
		  format :json

		  resource :shoppers do

			desc "Authenticate reatiler and return retailer object with authentication token.
				  Later the user is authenticated by the http header named Authentication-Token."

			get '/reasons' do

				result = JSON(SystemConfiguration.find_by(key:'deletion_reasons').value).to_a
				present result, with: API::V1::Shoppers::Entities::DeletionReasonEntity

			end
		  end
		end
	  end
	end
  end