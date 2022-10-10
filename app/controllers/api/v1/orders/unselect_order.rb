module API
  module V1
    module Orders
      class UnselectOrder < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :orders do
          params do
            requires :order_id, type: Integer, desc: "ID of the order", documentation: { example: 16 }
            requires :hardware_id, type: String , desc: "ID of Retailer Operator Device", documentation: { example: "cef76274f5bb0f12"}
          end
      
          put '/unselect/order' do
            order = Order.find_by(id: params[:order_id])
            if order.hardware_id
              order.update(hardware_id: nil)
              order.save
              order.retailer.unselect_order_notify(order.id,params[:hardware_id])
              1
            else
              0
            end
          end
        end
      end      
    end
  end
end