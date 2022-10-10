# frozen_string_literal: true

module API
  module V2
    module Orders
      class Status < Grape::API
        include TokenAuthenticable
        helpers Concerns::SmilesHelper
        version 'v2', using: :path
        format :json

        resource :orders do
          # **************************************************************************
          # -------------------------- Accept orders
          desc 'Allows accepting an order'
          params do
            requires :order_id, type: Integer, desc: 'ID of the retailer', documentation: { example: 16 }
            optional :delivery_vehicle, type: Integer, desc: 'Vehicle Type', documentation: { example: 1 }
          end

          put '/accept' do
            error!({ error_code: 401, error_message: 'Only Employee can accept orders!' }, 401) if current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            unless (order.retailer_id == current_employee.retailer_id) && OrderAllocation.for_order_employee(order.id, current_employee.id).active.exists?
              error!(CustomErrors.instance.retailer_not_have_order, 421)
            end
            error!(CustomErrors.instance.order_status('pending'), 421) unless order.status_id.zero?
            if params[:delivery_vehicle].present? && order.retailer_service_id == 1
              order.update(status_id: 1, delivery_vehicle: params[:delivery_vehicle], accepted_at: Time.new, picker_id: current_employee.try(:id), date_time_offset: request.headers['Datetimeoffset'])
            else
              order.update(status_id: 1, accepted_at: Time.new, picker_id: current_employee.try(:id), date_time_offset: request.headers['Datetimeoffset'])
            end
            current_employee.picking!
            EmployeeActivity.add_activity('Accept', current_employee.id, params[:order_id])
            present message: 'ok'
          end

          # **************************************************************************
          # -------------------------- Deliver orders
          desc 'Allows set order as delivered'
          params do
            requires :order_id, type: Integer, desc: 'ID of the order'
          end

          put '/deliver' do
            error!({ error_code: 401, error_message: 'Only employee can set order as delivered!' }, 401) if current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.order_status('ready to deliver, en_route or complete'), 421) unless [2, 11, 3].include? order.status_id
            order.update!(status_id: 5, updated_at: Time.new, date_time_offset: request.headers['Datetimeoffset'])
            current_employee.idle!
            EmployeeActivity.add_activity('Order Delivered', current_employee.id, params[:order_id])
            present message: 'ok'
          end

          # **************************************************************************
          # -------------------------- Deliver orders
          desc 'Allows set order as delivered'
          params do
            requires :order_id, type: Integer, desc: 'ID of the order'
          end

          put '/en_route' do
            error!({ error_code: 401, error_message: 'Only employee can set order as en_routed!' }, 401) if current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.order_status('ready to deliver'), 421) unless order.status_id == 11
            order.update!(status_id: 2, delivery_person_id: current_employee.try(:id), date_time_offset: request.headers['Datetimeoffset'])
            current_employee.delivering_order!
            EmployeeActivity.add_activity('Delivering Order', current_employee.id, params[:order_id])
            present message: 'ok'
          end

          # **************************************************************************
          # -------------------------- Cancel orders
          desc 'Allows canceling an order'

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
              # smiles_transactions_to_rollback(result.result) if result.result.payment_type_id == 4
              # present result.result, with: API::V1::Orders::Entities::ShowEntity
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
            end
          end

          # **************************************************************************
          # -------------------------- Process orders
          desc 'Allows further processing of an order'
          params do
            requires :order_id, type: Integer, desc: 'ID of the retailer', documentation: { example: 16 }
            requires :positions, type: Array do
              requires :was_in_shop, type: Boolean, desc: "Describes if the product is in shop's stock", documentation: { example: false }
              requires :position_id, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
            end
          end

          put '/process' do
            error!(CustomErrors.instance.only_for_employee, 421) if current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.retailer_not_have_order, 421) unless order.retailer_id == current_employee.retailer_id
            error!(CustomErrors.instance.order_status('accepted')) unless order.status_id == 1
            params[:positions].each do |position_data|
              order_position = OrderPosition.find_by(id: position_data[:position_id], order_id: order.id)
              order_position.update!(was_in_shop: position_data[:was_in_shop])
            end
            order.update!(status_id: 9, processed_at: Time.now, date_time_offset: request.headers['Datetimeoffset'])
            current_employee.idle!
            EmployeeActivity.add_activity('Picking Complete', current_employee.id, params[:order_id])
            present message: 'ok'
          end

          # **************************************************************************
          # -------------------------- Ready for Checkout Order
          desc 'Allows change order status to ready for checkout'

          params do
            requires :order_id, type: Integer, desc: 'ID of the order'
            optional :delivery_vehicle, type: Integer, desc: 'Vehicle Type', documentation: { example: 1 }
          end

          put '/ready_for_checkout' do
            error!(CustomErrors.instance.only_for_employee, 421) if current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.order_status('accepted'), 421) unless order.status_id == 1
            if params[:delivery_vehicle].present? && order.retailer_service_id == 1
              order.update!(status_id: 9, delivery_vehicle: params[:delivery_vehicle], processed_at: Time.now, date_time_offset: request.headers['Datetimeoffset'])
            else
              order.update!(status_id: 9, processed_at: Time.now, date_time_offset: request.headers['Datetimeoffset'])
            end
            current_employee.idle!
            EmployeeActivity.add_activity('Picking Complete', current_employee.id, params[:order_id])
            present message: 'ok'
          end

          # **************************************************************************
          # -------------------------- Ready to Deliver Order
          desc 'Allows change order status to ready to deliver'

          params do
            requires :order_id, type: Integer, desc: 'ID of the order', documentation: { example: 1_345_678 }
            optional :delivery_vehicle, type: Integer, desc: 'Vehicle Type', documentation: { example: 1 }
            requires :receipt_no, type: String, desc: 'Receipt number from retailer', documentation: { example: '7881927' }
            requires :amount, type: Float, desc: 'Receipt number from retailer', documentation: { example: 123.0 }
            optional :delivery_method, type: Integer, desc: 'Delivery method', documentation: { example: 0 }
            optional :receipt_image, type: Rack::Multipart::UploadedFile, desc: 'Single Image from retailer against receipt number', documentation: { example: 'mango.png' }
            optional :receipt_images, type: Array do
              optional :file, type: Rack::Multipart::UploadedFile, desc: 'Image from retailer against receipt number', documentation: { example: 'apple.png' }
            end
          end

          put '/ready_to_deliver' do
            error!(CustomErrors.instance.only_for_employee, 421) if current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.order_status('checking out'), 421) unless [7, 10, 12, 13].include?(order.status_id)
            update_debit_smiles_points(order, params[:amount].to_f, is_active: true)  if order.payment_type_id == 4
            # delivery_method = params[:delivery_method].present? ? params[:delivery_method] : 0
            price_variance = params[:amount].to_f > 0.0 ? (params[:amount].to_f - order.total_price_to_capture.to_f).round(2) : 0.0
            if params[:delivery_vehicle].present? && order.retailer_service_id == 1
              order.update!(status_id: 11, delivery_vehicle: params[:delivery_vehicle], receipt_no: params[:receipt_no], final_amount: params[:amount], price_variance: price_variance, date_time_offset: request.headers['Datetimeoffset'])
            else
              order.update!(status_id: 11, receipt_no: params[:receipt_no], final_amount: params[:amount], price_variance: price_variance, date_time_offset: request.headers['Datetimeoffset'])
            end

            if params[:receipt_image].present?
              rimg = Image.new(record: order)
              rimg.photo = ActionDispatch::Http::UploadedFile.new(params[:receipt_image])
              rimg.save(validate: false)
            end

            if params[:receipt_images].present?
              params[:receipt_images].each do |image|
                rimg = Image.new(record: order)
                rimg.photo = ActionDispatch::Http::UploadedFile.new(image)
                rimg.save(validate: false)
              end
            end

            accrual_smiles_points(order, params[:amount]) if order.payment_type_id != 4 && order.shopper.is_smiles_user
            current_employee.idle!
            EmployeeActivity.add_activity('Checkout Complete', current_employee.id, params[:order_id])
            present message: 'ok'
          end

          # **************************************************************************
          # -------------------------- Checking out Order
          desc 'Allows Checkout person to select order'

          params do
            requires :order_id, type: Integer, desc: 'ID of the order', documentation: { example: 1_345_678 }
          end

          put '/checking_out' do
            error!(CustomErrors.instance.only_for_employee, 421) if current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.order_status('ready for checkout'), 421) unless order.status_id == 9
            order.update!(status_id: 12, checkout_person_id: current_employee.try(:id), date_time_offset: request.headers['Datetimeoffset'])
            current_employee.checking_out!
            EmployeeActivity.add_activity('Checkout Start', current_employee.id, params[:order_id])
            present message: 'ok'
          end

          # **************************************************************************
          # -------------------------- Edit Order
          desc 'Allows edit order', entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'ID of the order'
          end

          put '/edit' do
            error!(CustomErrors.instance.not_allowed, 421) unless current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.shopper_not_have_order, 421) unless order.shopper_id == current_shopper.id
            error!(CustomErrors.instance.order_status('Pending'), 421) unless order.status_id.zero?
            order.status_id = 8
            ops = OrderPosition.where(order_id: order.id).select(:product_id, :amount)
            hash = {}
            ops.each { |op| hash[op.product_id.to_s] = op.amount }
            Redis.current.hset("order_#{order.id}", hash)
            Redis.current.expire("order_#{order.id}", 7200)
            PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: nil)
            present message: order.save!
          end
        end
      end
    end
  end
end
