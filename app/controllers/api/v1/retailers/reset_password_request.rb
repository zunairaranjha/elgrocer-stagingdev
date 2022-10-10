# frozen_string_literal: true

module API
  module V1
    module Retailers
      class ResetPasswordRequest < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :users do
          desc "Allows requesting a reset password token."
          params do
            optional :email, type: String, desc: 'Offset of products', documentation: { example: 10 }
          end
          post do
      
            user = Retailer.find_by(email: params[:email].downcase)
            error!({error_code: 404, error_message: "User does not exists"},404) if user.blank?
            user.send_password_reset
            'Ok'
          end
        end
      end      
    end
  end
end