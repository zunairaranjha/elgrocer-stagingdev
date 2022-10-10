class Orders::UpdateOrderPositions < Orders::Base

    integer :order_id
    integer :retailer_id
    array :positions
    float :amount, default: nil
    boolean :force_proceed, default: false
    string :receipt_no, default: nil

    validate :order_exists
    validate :retailer_has_order
    validate :positions_are_not_empty
    validate :current_status_is_accepted_or_failed

    def execute
        update_order_positions!
        if !(order.payment_type_id == 3 && credit_card.present?) || capture_online_payment
          order = update_order_status!
          shopper.update_order_notify(order, "Your order is on the way!")
          order.retailer.process_order_notify(order.id)
          order
        else
          error_case
        end
    end

    private

    def order
        @order ||= Order.find(order_id)
    end

    def update_order_position!(position_data)
        order_position = OrderPosition.find_by(id: position_data['position_id'], order_id: order.id)
        order_position.update!(was_in_shop: position_data['was_in_shop'])
    end

    def update_order_positions!
        positions.each do |position_data|
            update_order_position!(position_data)
        end
    end



    def update_order_status!
        order.update!(status_id: 2, processed_at: Time.new, price_variance: price_variance, receipt_no: receipt_no, final_amount: amount)
        order.save
        order
    end

    def current_status_is_accepted_or_failed
       errors.add(:status_id, "Current status was not 'accepted'!") unless [1,7].include?(order.status_id)
    end

    def error_case
      order.update(status_id: 7, price_variance: price_variance, receipt_no: receipt_no, final_amount: amount)
      shopper.online_payment_failed_order_notify(order)
      order.retailer.online_payment_failed_notify(order.id)
    end

    def amount_present?
      if amount.to_f > 0.0
        true
      else
        errors.add(:amount_not_present, "Please enter valid amount to proceed online payment")
        false
      end
    end

    def price_variance
      @order_total_amount ||= order_total_amount.to_f
      amount.to_f > 0.0 ? (amount.to_f - @order_total_amount).round(2) : 0.0
    end

    def check_amount_difference
      if amount_present? and ((price_variance.abs/@order_total_amount)*100).round(2) < 10.0
        true
      else
        errors.add(:amount_differs, "Total amount differs more than 10% of original value! Please confirmed total amount is #{amount}?")
        false
      end
    end

    def order_total_amount
      @total_amount ||= order.total_price_to_capture
    end

    def shopper
      @shopper||= order.shopper
    end

    def credit_card
      @credit_card ||= order.credit_card
    end

  def capture_online_payment
    #TELRGATEWAY.purchase(order.total_price_to_capture*100, order.credit_card.trans_ref)
    if amount_present?
      response = ''
      auth_amount = (order.card_detail["auth_amount"].to_i)/100.0
      if auth_amount >= amount and Analytic.where(owner: order,event_id: 21).count < 1 and Analytic.where(owner: order,event_id: 24).count < 1
        response = Payfort::Payment.new(order,shopper,credit_card,amount).capture
        unless response.downcase.eql?('success')
          RetailerMailer.payment_failed(order.id,response).deliver_later
          response = Payfort::Payment.new(order,shopper,credit_card,amount).purchase
        end
      elsif Analytic.where(owner: order,event_id: 21).count < 1 and Analytic.where(owner: order,event_id: 24).count < 2
        extra_amount = amount - auth_amount
        if extra_amount < 5.0
          extra_amount += 5.0
          auth_amount -= 5.0
        end
        response = Payfort::Payment.new(order,shopper,credit_card,extra_amount).purchase
        if response.downcase.eql?('success')
          response = Payfort::Payment.new(order,shopper,credit_card,auth_amount).capture
          unless response.downcase.eql?('success')
            RetailerMailer.payment_failed(order.id,response).deliver_later
            response = Payfort::Payment.new(order,shopper,credit_card,auth_amount).purchase
          end
        end
      else
        return true
      end
      if response.downcase.eql?('success')
        SmsNotificationJob.perform_later(shopper.phone_number.phony_normalized ,  I18n.t("sms.capture_payment", retailer_name: order.retailer.company_name, amount: amount, last_4_digit: credit_card.last4) )
        true
      else
        errors.add(:online_payment_failed, "Online Payment Failed due to #{response}.")
        false
      end
    else
      false
    end
  end
end
