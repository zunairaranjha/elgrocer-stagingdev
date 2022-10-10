# frozen_string_literal: true

module API
  module V1
    module Orders
      class Status < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :orders do
          # **************************************************************************
          # -------------------------- Accept orders
          desc 'Allows accepting an order', entity: API::V1::Orders::Entities::ShowEntity # add http codes
          params do
            requires :order_id, type: Integer, desc: 'ID of the retailer', documentation: { example: 16 }
          end

          put '/accept' do
            if current_shopper
              error!({ error_code: 401, error_message: 'Only retailers can accept orders!' }, 401)
            else
              f_parameters = params.merge({ retailer_id: current_retailer.id, status_id: 1 })
              result = ::Orders::UpdateStatus.run(f_parameters)
              if result.valid?
                # present result.result, with: API::V1::Orders::Entities::ShowEntity
                true
              else
                r_err = result.errors
                sts_err = r_err['status_id']

                if sts_err
                  error!({ error_code: 452, error_message: result.errors }, 452)
                else
                  error!({ error_code: 422, error_message: result.errors }, 422)
                end
              end
            end
          end

          # **************************************************************************
          # -------------------------- Deliver orders
          desc 'Allows set order as delivered', entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'ID of the order'
          end

          put '/deliver' do
            if current_shopper
              error!({ error_code: 401, error_message: 'Only retailer can set order as delivered!' }, 401)
            else
              f_parameters = params.merge(retailer_id: current_retailer.id)
              result = ::Orders::Deliver.run(f_parameters)
              if result.valid?
                # present result.result, with: API::V1::Orders::Entities::ShowEntity
                true
              else
                r_err = result.errors
                sts_err = r_err['status_id']

                if sts_err
                  error!({ error_code: 452, error_message: result.errors }, 452)
                else
                  error!({ error_code: 422, error_message: result.errors }, 422)
                end
              end
            end
          end

          # **************************************************************************
          # -------------------------- Cancel orders
          desc 'Allows accepting an order',
               entity: API::V1::Orders::Entities::ShowEntity,
               http_codes: [
                 200, 'Ok',
                 404, 'Order not found',
                 422, 'Order has wrong status',
                 423, 'Order is too young to be canceled'
               ]
          params do
            requires :order_id, type: Integer, desc: 'ID of the retailer', documentation: { example: 16 }
            optional :message, type: String, desc: 'Message describing why an order has been rejected', documentation: { example: 'All operators are busy' }
            optional :reason, type: Integer, desc: 'key', documentation: { example: 1 }
            optional :suggestion, type: String, desc: 'Suggestion what we can improve', documentation: { example: 'Deliver Order Quickly' }
          end

          put '/cancel' do
            if current_retailer
              f_parameters = params.merge({ retailer_id: current_retailer.id })
              result = ::Orders::RetailerCancelOrder.run(f_parameters)
            else
              f_parameters = params.merge({ shopper_id: current_shopper.id })
              result = ::Orders::ShopperCancelOrder.run(f_parameters)
            end
            result
            if result.valid?
              PromotionCodeRealization.where(order_id: result.result.id).delete_all
              # present result.result, with: API::V1::Orders::Entities::ShowEntity
              # smiles_transactions_to_rollback(result.result) if result.result.payment_type_id == 4
              true
            else
              r_err = result.errors.details

              if r_err[:order_id].present?
                error!({ error_code: 404, error_message: r_err }, 404)

              elsif r_err[:order_is_new].present?
                error!({ error_code: 423, error_message: r_err }, 423)

              elsif r_err[:status_is_not_pending].present?
                error!({ error_code: 422, error_message: r_err }, 422)

              else
                error!(500)
              end
              # if r_err[:order_422].empty?
              #   if r_err[:order_423].empty?
              #     error!({error_code: 404, error_message: result.errors},404)
              #   else
              #     error!({error_code: 404, error_message: result.errors},404)
              #   end
              # else
              #   error!({error_code: 422, error_message: result.errors},422)
              # end
            end
          end

          # **************************************************************************
          # -------------------------- Process orders
          desc 'Allows further processing of an order', entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'ID of the retailer', documentation: { example: 16 }
            requires :positions, type: Array do
              requires :was_in_shop, type: Boolean, desc: "Describes if the product is in shop's stock", documentation: { example: false }
              requires :position_id, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
            end
            optional :amount, type: Float, desc: 'Amount to deduct', documentation: { example: 30 }
            optional :force_proceed, type: Boolean, desc: 'To force processed the online payment', documentation: { example: false }
            optional :receipt_no, type: String, desc: 'Receipt number from retailer', documentation: { example: '7881927' }
          end

          put '/process' do
            target_user = current_retailer || current_shopper
            if target_user.class.name.downcase.eql?('shopper')
              error!({ error_code: 401, error_message: 'Only retailers can process orders!' }, 401)
            else
              f_parameters = params.merge(retailer_id: target_user.id)
              result = ::Orders::UpdateOrderPositions.run(f_parameters)
              if result.valid?
                # present result.result, with: API::V1::Orders::Entities::ShowEntity
                true
              else
                # r_err = result.errors
                # sts_err = r_err['status_id']
                if result.errors[:status_id].present?
                  error!({ error_code: 453, error_message: result.errors }, 453)
                elsif result.errors[:online_payment_failed].present?
                  error!({ error_code: 70_000, error_message: result.errors }, 453)
                elsif result.errors[:amount_not_present].present?
                  error!({ error_code: 70_001, error_message: result.errors }, 453)
                elsif result.errors[:amount_differs].present?
                  error!({ error_code: 70_002, error_message: result.errors }, 453)
                else
                  error!({ error_code: 422, error_message: result.errors }, 422)
                end
              end
            end
          end

          # **************************************************************************
          # -------------------------- Edit Order
          desc 'Allows edit order', entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'ID of the order'
          end

          put '/edit' do
            if current_retailer
              error!({ error_code: 401, error_message: 'Only shopper can edit order!' }, 401)
            else
              order = Order.find_by(id: params[:order_id])
              if order
                if order.status_id.zero?
                  order.status_id = 8
                  PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: nil)
                  order.save!
                else
                  error!({ error_code: 471, error_message: "Order #{order.status.humanize}!" }, 471)
                end
              else
                error!({ error_code: 404, error_message: 'Order not found!' }, 404)
              end
            end
          end
        end
      end
    end
  end
end
