class PartnerIntegration::GetSwift

  def initialize(order)
    @order = order
  end


  def create_booking(partner)
    api_key = partner.api_key || ENV['GETSWIFT_API_KEY']
    host_url = partner.api_url || ENV['GETSWIFT_URL']
    params = {
      "apiKey": api_key,
      "booking": {
        "reference": @order.id.to_s,
        "deliveryInstructions": @order.shopper_address_additional_direction.to_s,
        "itemsRequirePurchase": false,
        "pickupTime": Time.now.utc.iso8601,
        "pickupDetail": {
          "name": @order.retailer_company_name,
          # "phone": retailer.phone_number.to_s,
          # "email": retailer.email.to_s,
          "description": @order.retailer_company_name.to_s.truncate(100),
          "address": retailer_address.to_s.truncate(250),
          "additionalAddressDetails": {
            "stateProvince": shopper_address.administrative_area_level_1 || shopper_address.locality || "Dubai",
            "country": shopper_address.country || "United Arab Emirates",
            "suburbLocality": shopper_address.sublocality || shopper_address.locality || shopper_address.administrative_area_level_1 || "Dubai",
            # "postcode": "sample string 4",
            "latitude": retailer.latitude,
            "longitude": retailer.longitude
          }
        },
        "dropoffWindow": {
          "earliestTime": starting_time,
          "latestTime": latest_time
        },
        "dropoffDetail": {
          "name": @order.shopper_name,
          "phone": @order.shopper_phone_number.phony_normalized,
          "description": @order.shopper_address_location_address.to_s.truncate(99),
          "address": shopper_address_detail.to_s.truncate(250),
          "additionalAddressDetails": {
            "stateProvince": shopper_address.administrative_area_level_1 || shopper_address.locality || "Dubai",
            "country": shopper_address.country || "United Arab Emirates",
            "suburbLocality": shopper_address.sublocality || shopper_address.locality || shopper_address.administrative_area_level_1 || "Dubai",
            # "postcode": "sample string 4",
            "latitude": @order.shopper_address_latitude.to_f,
            "longitude": @order.shopper_address_longitude.to_f
          }
        },
        "orderPrice": (@order.total_value.to_f + @order.service_fee.to_f + @order.delivery_fee.to_f + @order.rider_fee.to_f),
        "payments": [
          {
            "method": payment_method,
            "amount": (@order.total_value.to_f + @order.service_fee.to_f + @order.delivery_fee.to_f + @order.rider_fee.to_f)
          }
        ]
      }
    }.to_json
    client = HTTPClient.new
    response = client.post host_url + "/api/public/v2/deliveries", params, 'Content-Type': "application/json"
    if response.status.to_i == 200
      body = JSON(response.body)
      @order.delivery_channel_id = 1
      @order.card_detail = @order.card_detail.to_h.merge({'job_identifier' => body["delivery"]["id"], 'tracking_url' => "https://app.getswift.co/Tracking/Map/#{body["delivery"]["id"]}"})
      @order.save
    end
    Analytic.add_activity(response.status.to_i == 200 ? "Booking Created" : "Booking Failed" , @order, response.body)
  end

  def cancel_booking(job_id, cancellation_note)
    params = {
        "apiKey": ENV['GETSWIFT_API_KEY'],
        "jobId": job_id,
        "cancellationNotes": cancellation_note
    }.to_json
    client = HTTPClient.new
    response = client.post ENV['GETSWIFT_URL'] + "/api/public/v2/deliveries/cancel", params, 'Content-Type': "application/json"
    Analytic.add_activity(response.status.to_i == 200 ? "Booking Cancelled" : "Booking Cancellation Failed" , @order, response.body)
  end

  def payment_method
    if @order.payment_type_id == 1
      "CashOnDelivery"
    elsif @order.payment_type_id == 2
      "CreditCardOnDelivery"
    else
      "Prepaid"
    end
  end

  def shopper_address_detail
    if @order.shopper_address_type_id ==  0
      address = [@order.shopper_address_apartment_number, @order.shopper_address_floor, @order.shopper_address_building_name, @order.shopper_address_street, @order.shopper_address_name, @order.shopper_address_area]
    elsif @order.shopper_address_type_id == 1
      address = [@order.shopper_address_house_number, @order.shopper_address_street, @order.shopper_address_name, @order.shopper_address_area]
    else
      address = [@order.shopper_address_apartment_number, @order.shopper_address_floor, @order.shopper_address_building_name, @order.shopper_address_street, @order.shopper_address_name, @order.shopper_address_area]
    end
    address.reject!(&:blank?).uniq
    address.join(' - ')
  end

  def retailer_address
    Geocoder.search([retailer.latitude, retailer.longitude]).first.try(:address)
  end

  def retailer
    @retailer ||= @order.retailer
  end

  def shopper_address
    @shopper_address ||= @order.shopper_address
  end

  def latest_time
    slot_diff = @order.delivery_slot_id && @order.delivery_slot && (@order&.delivery_slot&.end.to_i - @order&.delivery_slot&.start.to_i) || 1.minute
    if ((@order.estimated_delivery_at + slot_diff) - Time.now) > 30.minutes
      (@order.estimated_delivery_at + slot_diff).utc.iso8601
    else
      (Time.now + 30.minute).utc.iso8601
    end
  end

  def starting_time
    @order.delivery_slot_id && @order.estimated_delivery_at.utc.iso8601 || @order.created_at.utc.iso8601
  end
end