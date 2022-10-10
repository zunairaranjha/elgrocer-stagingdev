class PartnerIntegration::UnionCoop
  
  def initialize(order,partner)
    @partner = partner
    @order = order
    @host_url = partner.api_url
    @headers = {'username': partner.user_name, 'password': partner.password, 'Content-Type': 'application/x-www-form-urlencoded'}
    proxy = URI(ENV['PROXY_URL'])
    @client = HTTPClient.new(proxy)
    @client.set_proxy_auth(proxy.user,proxy.password)
  end

  def create_new_order
    body = {
      'order_data' => {
        'order_id' => @order.id,
        'branch' => @partner.branch_code,
        'order_date_time' => @order.created_at,
        'delivery_time' => @order.estimated_delivery_at,
        'payment_mode' => payment_method,
        'total_value' => total_value
      }.to_json,
      'address_info' => {
        'firstname' => @order.shopper_name,
        'lastname' => '',
        'street' => shopper_address&.street || @order.retailer_street,
        'building' => shopper_address&.building_name || '',
        'city' => shopper_address&.locality || @order.retailer_company_address,
        'postcode' => '',
        'email' => '',
        'telephone' => ''
      }.to_json
    }
    response = @client.post @host_url + '/onlinepartners/api/sendOrder', body, @headers
    Analytic.add_activity('Order Notify Partner', @order, detail: response.body)
  end

  def payment_method
    if @order.payment_type_id == 1
      'COD'
    elsif @order.payment_type_id == 2
      'CARD'
    else
      'PAID'
    end
  end

  def total_value
    op = @order.order_positions
    value_sum = 0
    op.each do |position|
      value_sum += ((position.shop_price_dollars + (position.shop_price_cents).to_f/100).to_f).round(2) * position.amount
    end
    value_sum.round(2)
  end

  def shopper_address
    @shopper_address ||= @order.shopper_address
  end

end
