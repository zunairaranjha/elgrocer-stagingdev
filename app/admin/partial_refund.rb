ActiveAdmin.register OnlinePaymentLog, as: 'partial_refund' do
  menu false
  permit_params :order_id, :merchant_reference

  form html: { enctype: 'multipart/form-data' } do |f|
    order = Order.select(:id, :final_amount, :refunded_amount).find_by(id: f.object.order_id)
    f.inputs 'Partial Refund' do
      f.input :order_id, input_html: { readonly: true }
      f.input :merchant_reference, input_html: { readonly: true }
      f.input :refund_amount, hint: "Refund Amount is in Cents e.g 100 cents = 1 AED (The Remaining Captured Amount is #{(order.final_amount * 100).to_i - order.refunded_amount.to_i} cents)"
    end
    f.actions do
      f.action :submit, label: 'Refund Amount'
    end
  end

  controller do
    def create
      return if invalid_refund_entry

      order = Order.find_by(id: params[:online_payment_log][:order_id])
      return if invalid_refund_amount(order)

      req = { 'reference' => "O-#{order.card_detail['trans_ref']}-#{order.id}",
              'originalReference' => params[:online_payment_log][:merchant_reference],
              'modificationAmount' => { currency: 'AED', value: params[:online_payment_log][:refund_amount] },
              'additionalData' => {
                industryUsage: 'DelayedCharge'
              } }
      response = Adyenps::Checkout.refund(req)
      create_log(order, response)
      redirect_to admin_online_payment_logs_path, alert: 'Refund Amount Request is under Process, Please Refresh the page after some Time To Get the Respose'
    end

    def create_log(order, res)
      begin
        OnlinePaymentLog.create(method: 'REFUND REQUESTED', order_id: order.id,
                                status: 'waiting',
                                fort_id: res.response['pspReference'],
                                details: { owner_id: current_admin_user.id, owner_email: current_admin_user.email })
      rescue
        nil
      end
      Analytic.post_activity("Adyen:REFUND REQUESTED:#{res.status == 200 ? 'success' : 'failed'}", current_admin_user, detail: res.to_json, date_time_offset: request.headers['Datetimeoffset'])
      res
    end

    def invalid_refund_entry
      return if params[:online_payment_log][:refund_amount].to_i.positive?

      redirect_to new_admin_partial_refund_path('online_payment_log[order_id]' => params[:online_payment_log][:order_id],
                                                'online_payment_log[merchant_reference]' => params[:online_payment_log][:merchant_reference]
                  ), alert: 'Refunded Amount must be greater than 0'
      true
    end

    def invalid_refund_amount(order)
      return unless order.final_amount < (order.refunded_amount.to_i + params[:online_payment_log][:refund_amount].to_i) / 100.0

      redirect_to new_admin_partial_refund_path('online_payment_log[order_id]' => params[:online_payment_log][:order_id],
                                                'online_payment_log[merchant_reference]' => params[:online_payment_log][:merchant_reference]
                  ), alert: "Refunded Amount Should be less than or equal to #{(order.final_amount * 100).to_i - order.refunded_amount.to_i} cents For Order #{order.id}"
      true
    end

  end
end
