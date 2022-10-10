module API
  module V1
    module CreditCards
      class Delete < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :credit_cards do
          desc "Allows deleting of an credit card of a shopper. Requires authentication"
          params do
            requires :card_id, type: Integer, desc: "Id of a credit card"
            optional :cancel_orders, type: Boolean, desc: "Cancel orders or not", documentation: { example: false }
          end
      
          delete do
            target_user = current_shopper
            orders = Order.where(shopper_id: target_user.id, credit_card_id: params[:card_id], status_id: [0,1,6])
            if orders.length < 1 or params[:cancel_orders]
              if params[:cancel_orders]
                orders.each do |order|
                  order.update_attributes(status_id: 4, canceled_at: Time.now, user_canceled_type: 4, updated_at: Time.now)
                end
              end
              card = CreditCard.find_by(shopper_id: target_user.id, id: params[:card_id])
              if card
                card.update(is_deleted: true)
                PayfortJob.perform_later('inactive_card', nil, card)
                true
              else
                error!({error_code: 422, error_message: "Card not found"},422)
              end
            else
              error!({error_code: 423, error_message: I18n.t("errors.card_delete_cancel_order")},423)
            end
          end
      
        end
      end
      
    end
  end
end