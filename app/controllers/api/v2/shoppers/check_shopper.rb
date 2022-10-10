# frozen_string_literal: true

module API
  module V2
    module Shoppers
      class CheckShopper < Grape::API
        version 'v2', using: :path
        format :json

        resource :shoppers do
          desc "Check if shopper with provided email is present."

          params do
            requires :email, type: String, desc: 'Shopper Email'
          end

          post '/check_shopper' do
            shopper = Shopper.select(:id, :email).find_by(email: params[:email].downcase)
            if shopper.present?
              'Shopper with this email exist'
            else
              error!({ error_code: 403, error_message: "Shopper does not exist" }, 403)
            end
          end
        end
      end
    end
  end
end