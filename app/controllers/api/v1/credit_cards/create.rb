module API
  module V1
    module CreditCards
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :credit_cards do
          desc "Allows creation of a Credit Card of a shopper. Requires authentication", entity: API::V1::CreditCards::Entities::ShowEntity
          params do
            optional :card_type, type: String, desc: "Credit Card Type"
            requires :last4, type: String, desc: "Credit Card Last 4 Digits"
            optional :country, type: String, desc: "Country"
            optional :first6, type: String, desc: "Credit Card First 6 Digits"
            optional :expiry_month, type: Integer, desc: "Credit Card Expiry Month"
            optional :expiry_year, type: Integer, desc: "Credit Card Expiry Year"
            requires :trans_ref, type: String, desc: "Transaction Reference Number"
            optional :cvv, type: Integer, desc: "Card Security Number"
          end
      
          post do
            card = CreditCard.find_or_initialize_by(trans_ref: params[:trans_ref])
            card.shopper_id = current_shopper.id
            card.card_type = params[:card_type]
            card.last4 = params[:last4]
            card.country = params[:country]
            card.first6 = params[:first6]
            card.expiry_month = params[:expiry_month]
            card.expiry_year = params[:expiry_year]
            card.cvv = params[:cvv]
            result = card.save
            if result
              present card, with: API::V1::CreditCards::Entities::ShowEntity
            else
              error!(result.errors, 422)
            end
          end
        end
      end      
    end
  end
end