# frozen_string_literal: true

module API
  module V1
    module Sessions
      class SignOutRetailer < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :sessions do
      
          desc "Logs a Retailer out"
      
          params do
            optional :hardware_id, type: String, desc: "Retailer's hardware_id"
            optional :registration_id, type: String, desc: "Retailer's registration_id"
          end
      
          delete do
            registration_id = params[:registration_id]
            hardware_id = params[:hardware_id]
            current_retailer.delete_push_token(registration_id, hardware_id)
            result = {message: 'ok'}
            result
          end
        end
      end      
    end
  end
end