module API
  module V2
    module Retailers
      class PaymentMethods < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :retailers do
          desc 'Get Payment methods of Retailer and list of Shopper Cards '

          params do
            requires :retailer_id, type: Integer, desc: 'Retailer ID', documentation: { example: 16 }
          end

          get '/payment_methods' do
            error!(CustomErrors.instance.update_to_latest, 421) unless current_shopper
            service_id = request.headers['Service-Id'] || 1
            payment_types = AvailablePaymentType.joins(:retailer_has_available_payment_types).where(retailer_has_available_payment_types: { retailer_id: params[:retailer_id], retailer_service_id: service_id })
            online = payment_types.select { |payment_type| payment_type.id == 3 }
            cards = online.blank? ? [] : current_shopper.credit_cards.where(is_deleted: false).order(:id)
            result = { payment_types: payment_types, cards: cards }
            present result, with: API::V1::Retailers::Entities::PaymentTypesAndCard
          end
        end
      end
    end
  end
end