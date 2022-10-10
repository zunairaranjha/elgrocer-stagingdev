# frozen_string_literal: true

ActiveAdmin.register Order, as: 'online_payment_audit' do
  menu parent: 'Orders'
  config.batch_actions = false
  actions :all, except: [:new, :edit, :destroy]

  member_action :charge_payment, method: :post do
    order = resource
    shopper = order.shopper
    credit_card = order.credit_card
    amount = params['diff'].to_f.abs
    response = Payfort::Payment.new(order, shopper, credit_card, amount).purchase("#{order.id}-#{(Time.now.to_f * 10).to_i}")
    query = ''
    query += "page=#{params['page']}" if params['page'].present?
    if params['keys'].present?
      keys = params['keys'].split('/')
      values = params['values'].split('/')
      counter = 0
      keys.each do |key|
        if counter > 0
          query += "&q[#{key}]=#{values[counter]}"
        elsif params['page'].present?
          query += "&q[#{key}]=#{values[counter]}"
        else
          query = "q[#{key}]=#{values[counter]}"
        end
        counter += 1
      end
      query += '&commit=Filter&order=created_at_desc' if params['commit'].present?
    end
    if response.downcase.eql?('success')
      order.update(status_id: 2, updated_at: Time.now)
      redirect_to admin_online_payment_audits_path + "?#{query}", flash: { notice: "Payment for order #{order.id} is deducted successfully." }
    else
      amount = order.card_detail['auth_amount'].to_i / 100.0
      res = Payfort::Payment.new(order, shopper, credit_card, amount).capture
      if res.downcase.eql?('success')
        redirect_to admin_online_payment_audits_path + "?#{query}", flash: { notice: "Payment for order #{order.id} is captured successfully." }
      else
        redirect_to admin_online_payment_audits_path + "?#{query}", flash: { error: "Unable to deduct payment for order #{order.id}. PURCHASE failed due to: #{response},  CAPTURE failed due to: #{res}" }
      end
    end
  end

  # includes :online_payment_logs

  config.sort_order = 'created_at_desc'

  controller do
    def scoped_collection
      resource_class.joins("LEFT JOIN online_payment_logs AS opl ON opl.order_id = orders.id AND opl.method ~* 'capture|purchase' AND opl.status = 'success'")
                    .where(payment_type_id: 3)
                    .group('orders.id')
                    .select("orders.*, coalesce(SUM(opl.amount), 0)::decimal AS full_amount, coalesce(SUM(opl.amount) FILTER (WHERE opl.method = 'CAPTURE'), 0)::decimal AS capt_amount,  coalesce(SUM(opl.amount) FILTER (WHERE opl.method = 'PURCHASE'), 0)::decimal AS pur_amount")
                    .having("(orders.status_id = 4 AND (coalesce(SUM(opl.amount), 0)::decimal > 0) OR (coalesce(SUM(opl.amount), 0)::decimal = 0 AND coalesce(orders.final_amount, 0)::decimal > 0))
                     OR (orders.status_id IN (-1, 0, 1, 6, 8, 9, 10, 11) AND date(estimated_delivery_at) < date(now()))
                     OR (orders.status_id = 7 AND (coalesce(SUM(opl.amount), 0)::decimal = 0 OR (coalesce(SUM(opl.amount), 0)::decimal - coalesce(orders.final_amount, 0)::decimal <= 0)))
                     OR (orders.status_id IN (2, 3, 5, 12, 13, 14) AND (coalesce(SUM(opl.amount), 0)::decimal = 0 OR ((coalesce(SUM(opl.amount), 0)::decimal - coalesce(orders.final_amount, 0)::decimal) <> 0)))")
    end
  end

  index do
    column :id do |ord|
      link_to(ord.id, admin_order_path(ord.id)) rescue ord.id
    end
    column :created_at
    column('Retailer Name') { |c| link_to(c.retailer_company_name, admin_retailer_path(c.retailer_id)) rescue c.retailer_company_name }
    # column('Shopper name') { |c| link_to(c.shopper_name, admin_shopper_path(c.shopper_id)) rescue c.shopper_name }
    column 'Total Value' do |ord|
      ord.total_value.to_f.round(2)
    end
    column :final_amount
    column :payment_type
    column :status
    column 'CAP_AMT', &:capt_amount
    column 'PUR_AMT', &:pur_amount
    column 'FULL_AMT' do |ord|
      ord.full_amount.round(2)
    end
    column 'DIFF' do |ord|
      (ord.full_amount - ord.final_amount.to_f).round(2)
    end
    column 'Audit Area' do |ord|
      if ord.status_id == 4
        'Canceled Orders'
      elsif [-1, 0, 1, 6, 8, 9, 10, 11].include?(ord.status_id)
        'Unprocessed Orders'
      elsif ord.status_id == 7
        'Failed Online Payment'
      elsif [2, 3, 5, 12, 13, 14].include?(ord.status_id)
        'Short Payment'
      end
    end
    column 'ERROR' do |ord|
      if ord.status_id == 4
        if ord.full_amount.positive?
          'Cncl’d AND Paid: Refund?'
        elsif ord.full_amount.zero? and ord.final_amount.to_f.positive?
          'Cncl’d AFTER Checkout.Delivered?'
        else
          '-'
        end
      elsif [-1, 0, 1, 6, 8, 9, 10, 11].include?(ord.status_id)
        if Time.now.beginning_of_day - ord.estimated_delivery_at.beginning_of_day > 0.0
          'Why not processed?'
        else
          '-'
        end
      elsif ord.status_id == 7
        if ord.full_amount.zero?
          'Pmt Failed! Delivered?'
        elsif (ord.full_amount - ord.final_amount.to_f).zero?
          'Paid, then Pmt Failed! Delivered?'
        elsif (ord.full_amount - ord.final_amount.to_f) < 0
          'Partial Paid, then Pmt Failed! Delivered?'
        else
          '-'
        end
      elsif [2, 3, 5, 12, 13, 14].include?(ord.status_id)
        if ord.full_amount.zero?
          'Not Paid!'
        elsif (ord.full_amount - ord.final_amount.to_f) < 0
          'Underpaid!'
        elsif (ord.full_amount - ord.final_amount.to_f) > 0
          'Overpaid! Refund?'
        else
          '-'
        end
      end
    end
    actions defaults: false do |ord|
      diff = (ord.full_amount - ord.final_amount.to_f).round(2)
      if diff < 0.0
        if params['q'].present?
          params[:keys] = params['q'].keys
          params[:values] = params['q'].values
        end
        params[:diff] = diff.to_s
        button_to 'Charge', "/admin/online_payment_audits/#{ord.id}/charge_payment", method: :post, params: params.permit!
      end
    end
  end

  filter :created_at
  filter :audit_area_in, label: 'Audit Area', as: :select, collection: proc { controller.audit_areas }

  controller do
    def audit_areas
      { 'Canceled Orders' => 1, 'Unprocessed Orders' => 2, 'Failed Online Pmt' => 3, 'Short Payment' => 4 } # , "No Payment" => 5 }
    end
  end

end
