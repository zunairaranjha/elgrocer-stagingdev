module API
  module V1
    module Orders
      class OnlinePaymentDetails < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :orders do
          desc 'Update the Online payment details of the order'
      
          params do
            requires :payment_type_id, type: Integer, desc: 'Payment Type of the user', documentation: { example: 3 }
            requires :order_id, type: Integer, desc: 'Order Id', documentation: {example: 12345678}
            optional :merchant_reference, type: String, desc: 'Merchant Reference of payment', documentation: { example: '3456789' }
            optional :auth_amount, type: Integer, desc: 'Authorization Amount', documentation: { example: 2345 }
            optional :card_id, type: Integer, desc: 'Credit card id', documentation: { example: 23 }
          end
      
          put '/online_payment_details' do
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.order_status('waiting_for_online_payment_detail'), 421) unless [-1,0].include? order.status_id
            if params[:payment_type_id].to_i == 3
              credit_card = CreditCard.find_by(id: params[:card_id])
              error!(CustomErrors.instance.card_not_found, 421) unless credit_card
              error!(CustomErrors.instance.payment_details_missing, 421) unless (params[:auth_amount].present? and params[:merchant_reference].present?)
              order.update!(status_id: 0, merchant_reference: params[:merchant_reference], credit_card_id: params[:card_id], card_detail: credit_card.attributes.merge(auth_amount: params[:auth_amount]))
              {message: 'ok'}
            else
              retailer_payment_type = RetailerHasAvailablePaymentType.find_by(retailer_id: order.retailer_id, available_payment_type_id: params[:payment_type_id])
              error!(CustomErrors.instance.not_have_payment_type, 421) unless retailer_payment_type
              order.update!(payment_type_id: params[:payment_type_id], status_id: 0)
              ShopperMailer.order_placement(order.id).deliver_later
              {message: 'ok'}
            end
          end
        end
      end      
    end
  end
end