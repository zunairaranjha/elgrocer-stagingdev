# frozen_string_literal: true

class PartnerIntegration::LocusSh

  def initialize(order)
    @order = order
  end

  def create_bookingMPMD(partner)
    # api_key = partner.api_key || ENV['LOCUSSH_API_KEY']
    # host_url = partner.api_url || ENV['LOCUSSH_URL']
    # user_name = partner.user_name || ENV['LOCUSSH_USERNAME']
    # password = partner.password || ENV['LOCUSSH_PASSWORD']

    params = {
      "taskId": @order.id, # order/invoice/reference ID of the order being created - mandatory#
      # "taskPriority": 0, #priority of the order if required - optional#
      # "sourceOrderId": "string", #alternate Id that has to be added - optional#
      "teamId": !partner.api_key.blank? && partner.api_key || 'dubai', # zone/team to which the order is mapped#
      # "lineItems": [ #can be optional - these are details about the items inside the order - array#
      #   {
      #     "id": "string", #item Id that has to be moved - optional#
      #     "name": "string", #name of the item that has to be moved - optional#
      #     "quantity": 0, #quantity of the above item that has to be moved - optional#
      #     "price": {
      #       "amount": 0, #price of the  line item - optional#
      #       "currency": "AED", #currency - AED in case of UAE#
      #     },
      #     "parts": [ #optional units of volume and weight at a line item level#
      #       {
      #         "volume": {
      #           "unit": "ITEM_COUNT", #unit will always be ITEM_COUNT#
      #           "value": 0 #total volume of the item - this is just a unit and not metres cube - optional#
      #         },
      #         "weight": 0, #weight of the item in gms - optional#
      #       }
      #     ]
      #   }
      # ],
      # "skills": [ #skills are segregation - frozen to go to frozen vehicles - optional#
      #   "string"
      # ],
      # "resources": [ #extra units of capacity measurement - optional#
      #   {
      #     "name": "string", #name could be Crate Count or Box Count#
      #     "value": 0 #value of the above unit#
      #   }
      # ],
      # "temperatureThreshold": {
      #   "lowerThreshold": 0,
      #   "higherThreshold": 0,
      #   "temperatureType": "CHILLED"
      # },
      "customFields": {
        "additionalProp1": @order.shopper_address_additional_direction.to_s,
        "additionalProp2": @order.shopper_note,
        # "additionalProp3": "string"
      },
      "autoAssign": false, # if Locus has to identify best driver, true, if not false#
      # "dryRun":false/true, #incase confirmation is required beforehand if order can be serviced without actually creating the order, true, default false#
      # "scanId":"string", #if barcode scanning is required on pickup and delivery#
      "pickupVisitName": @order.id.to_s, # any custom visit name that needs to be displayed on the rider app#
      # "pickupLocationId": "string", #pass the location Id stored on the location master if used - optional#
      "pickupContactPoint": { # details about the retailer for pickup - displays on the app#
        "name": retailer.company_name, # Name of the retailer#
        "number": retailer.phone_number # Contact Number - optional#
      },
      "pickupLocationAddress": {
        # "placeName": "string", #place name is a landmark - optional#
        "localityName": shopper_address.locality || shopper_address.administrative_area_level_1 || 'Dubai', # locality of the retailer - optional#
        "formattedAddress": retailer_address.to_s, # string address of the retailer - preferable to have it for navigation#
        "subLocalityName": shopper_address.sublocality || shopper_address.locality || shopper_address.administrative_area_level_1 || 'Dubai',
        "city": shopper_address.administrative_area_level_1 || 'Dubai', # city of the retailer#
        "countryCode": 'AE', # country code - AE#
        "locationType": 'CLIENT' # always CLIENT - optional#
      },
      "pickupLatLng": {
        "lat": retailer.latitude, # latitude of the retailer - 3 decimals minimum for more accuracy#
        "lng": retailer.longitude # longitude of the retailer - 3 decimals minimum for more accuracy#
      },
      "pickupDate": starting_time, # date of order creation#
      "pickupSlot": {
        "start": Time.now.utc.iso8601, # (starting_time.to_time - 1.hours).utc.iso8601, #order acceptance time of the retailer - when the timer starts#
        "end": latest_time # acceptance time + promised SLA time - when the promised delivery time# 
      },
      # "pickupSlots": [ #multislotted pickups - optional#
      #   {
      #     "start": "2021-02-26T09:48:37.175Z",
      #     "end": "2021-02-26T09:48:37.175Z"
      #   }
      # ],
      "pickupTransactionDuration": Integer(SystemConfiguration.find_by("key ~* 'locus.pickuptransactionduration'")&.value || 10).minute, # time to be spent at the retailer location by driver#
      "pickupAmount": {
        "amount": {
          "amount": (@order.total_value.to_f + @order.service_fee.to_f + @order.delivery_fee.to_f + @order.rider_fee.to_f), # value to be transacted with the customer#
          "currency": 'AED' # always AED#
        },
        "exchangeType": 'NONE' # type of transaction - GIVE/COLLECT/PAID#
      },
      "pickupAppFields": { # pickup notes that will popup in the app as an array#
        "items": [
          {
            "item": !@order.shopper_note.blank? && @order.shopper_note || order_path, # header of what is being passed#
            "format": 'TEXT', # format - URL/TEXT - URL has to be a hyperlink#
            "additionalValues": {
              "additionalProp1": order_path,
              "additionalProp2": @order.shopper_note,
              "additionalProp3": @order.shopper_address_additional_direction
            }
          }
        ]
      },
      "dropVisitName": @order.shopper_name, # any custom visit name that needs to be displayed on the rider app#
      "dropContactPoint": { # details about the customer for drop - displays on the app#
        "name": @order.shopper_name, # Name of the customer#
        "number": @order.shopper_phone_number.phony_normalized # Contact Number - optional#
      },
      "dropLocationAddress": {
        # "placeName":"string", #place name is a landmark - optional#
        "localityName": shopper_address.locality || shopper_address.administrative_area_level_1 || 'Dubai', # locality of the retailer - optional#
        "formattedAddress": shopper_address_detail, # string address of the retailer - preferable to have it for navigation#
        "subLocalityName": shopper_address.sublocality || shopper_address.locality || shopper_address.administrative_area_level_1 || 'Dubai',
        "city": shopper_address.administrative_area_level_1 || 'Dubai', # city of the retailer#
        "countryCode": 'AE', # country code - AE#
        "locationType": 'CLIENT' # always CLIENT - optional# #STANDALONE_APARTMENT, GATED_COMMUNITY, INDEPENDENT_PREMISES
      },
      "dropLatLng": {
        "lat": @order.shopper_address_latitude.to_f, # latitude of the retailer - 3 decimals minimum for more accuracy#
        "lng": @order.shopper_address_longitude.to_f # longitude of the retailer - 3 decimals minimum for more accuracy#
      },
      "dropDate": @order.estimated_delivery_at.utc.iso8601, # date of order creation#
      "dropSlot": {
        "start": starting_time, # order acceptance time of the retailer - when the timer starts#
        "end": latest_time # acceptance time + promised SLA time - when the promised delivery time# 
      },
      # "dropSlots": [ #multislotted drops - optional#
      #   {
      #     "start": "2021-02-26T09:48:37.175Z",
      #     "end": "2021-02-26T09:48:37.175Z"
      #   }
      # ],
      "dropTransactionDuration": Integer(SystemConfiguration.find_by("key ~* 'locus.droptransactionduration'")&.value || 15).minute, # time to be spent at the customer location by driver#
      "dropAmount": {
        "amount": {
          "amount": (@order.total_value.to_f + @order.service_fee.to_f + @order.delivery_fee.to_f + @order.rider_fee.to_f), # value to be transacted with the customer#
          "currency": 'AED' # always AED#
        },
        "exchangeType": payment_method # type of transaction - GIVE/COLLECT/PAID#
      },
      "dropAppFields": { # pickup notes that will popup in the app as an array#
        "items": [
          {
            "item": !@order.shopper_address_additional_direction.blank? && @order.shopper_address_additional_direction || order_path, # header of what is being passed#
            "format": 'TEXT', # format - URL/TEXT - URL has to be a hyperlink#
            "additionalValues": {
              "additionalProp1": order_path,
              # "additionalProp2": Rails.env.production?,
              # "additionalProp3": "string"
            }
          }
        ]
      },
      "volume": {
        "value": @order.order_positions.where(was_in_shop: true).count, # total volume of the order in the unit of capacity - if order count is the capacity, value is 1#
        "unit": 'ITEM_COUNT' # unit to map - always ITEM_COUNT
      }
    }.to_json

    # client = HTTPClient.new
    # client.set_auth("%s/client/%s/spmdtask/%s" % [host_url, user_name, @order.id], user_name, password)
    # headers = {
    #   "Authorization" => "Basic " + Base64.encode64(user_name + ':' + password).gsub("\n",''),
    #   'Content-Type': "application/json"
    # }
    # response = client.put "%s/client/%s/mpmdtask/%s" % [host_url, user_name, @order.id], params, headers
    response = sendRequest(partner, 'put', '%s/client/%s/mpmdtask/%s' % [partner.api_url, partner.user_name, @order.id], params)
    @order.update(delivery_channel_id: DeliveryChannel.find_or_create_by(:name => 'Locus').id) if response.status.to_i == 200
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus Task Created' : 'Locus Task Failed', @order, response.body)
  end

  def create_booking(partner)
    params = {
      "taskId": @order.id, # order/invoice/reference ID of the order being created - mandatory#
      # "taskPriority": 0, #priority of the order if required - optional#
      # "sourceOrderId": "string", #alternate Id that has to be added - optional#
      "teamId": partner.api_key.present? && partner.api_key || 'dubai', # zone/team to which the order is mapped#
      "homebaseId": "RET#{@order.retailer_id}",
      "skills": [# skills are segregation - frozen to go to frozen vehicles - optional#
        # @order.retailer.retailer_type == 2 && 'bike' || @order.delivery_vehicle.present? && @order.delivery_vehicle || 'car'
      if @order.delivery_vehicle.present?
              @order.delivery_vehicle
      elsif @order.retailer.retailer_type == 2
        'bike'
      else
        'car'
      end
      ],
      # "resources": [ #extra units of capacity measurement - optional#
      #   {
      #     "name": "string", #name could be Crate Count or Box Count#
      #     "value": 0 #value of the above unit#
      #   }
      # ],
      # "temperatureThreshold": {
      #   "lowerThreshold": 0,
      #   "higherThreshold": 0,
      #   "temperatureType": "CHILLED"
      # },
      "customFields": {
        "EGOrderStatus": @order.status,
        "EGOrderVehicle": @order.delivery_vehicle.to_s,
        # "additionalProp3": "string"
      },
      "taskType": 'DROP',
      "autoAssign": true, # if Locus has to identify best driver, true, if not false#
      # "dryRun":false/true, #incase confirmation is required beforehand if order can be serviced without actually creating the order, true, default false#
      # "scanId":"string", #if barcode scanning is required on pickup and delivery#
      "visitName": @order.shopper_name, # any custom visit name that needs to be displayed on the rider app#
      "contactPoint": { # details about the customer for drop - displays on the app#
        "name": @order.shopper_name, # Name of the customer#
        "number": @order.shopper_phone_number.phony_normalized&.truncate(15) # Contact Number - optional#
      },
      "locationAddress": {
        # "placeName":"string", #place name is a landmark - optional#
        "localityName": shopper_address.locality || shopper_address.administrative_area_level_1 || 'Dubai', # locality of the retailer - optional#
        "formattedAddress": shopper_address_detail, # string address of the retailer - preferable to have it for navigation#
        "subLocalityName": shopper_address.sublocality || shopper_address.locality || shopper_address.administrative_area_level_1 || 'Dubai',
        "city": shopper_address.administrative_area_level_1 || 'Dubai', # city of the retailer#
        "countryCode": 'AE', # country code - AE#
        "locationType": 'CLIENT' # always CLIENT - optional# #STANDALONE_APARTMENT, GATED_COMMUNITY, INDEPENDENT_PREMISES
      },
      "latLng": {
        "lat": @order.shopper_address_latitude.to_f, # latitude of the retailer - 3 decimals minimum for more accuracy#
        "lng": @order.shopper_address_longitude.to_f # longitude of the retailer - 3 decimals minimum for more accuracy#
      },
      # "dropDate": @order.estimated_delivery_at.utc.iso8601, #date of order creation#
      "slot": {
        "start": starting_time, # order acceptance time of the retailer - when the timer starts#
        "end": latest_time # acceptance time + promised SLA time - when the promised delivery time#
      },
      "transactionDuration": Integer(SystemConfiguration.find_by("key ~* 'locus.droptransactionduration'")&.value || 15).minute, # time to be spent at the customer location by driver#
      "amountTransaction": {
        "amount": {
          "amount": (@order.total_value.to_f + @order.service_fee.to_f + @order.delivery_fee.to_f + @order.rider_fee.to_f), # value to be transacted with the customer#
          "currency": 'AED' # always AED#
        },
        "exchangeType": payment_method # type of transaction - GIVE/COLLECT/PAID#
      },
      "appFields": { # pickup notes that will popup in the app as an array#
        "items": [
          {
            "item": "ORD##{@order.id}", # header of what is being passed#
            "format": 'URL', # format - URL/TEXT - URL has to be a hyperlink#
            "additionalValues": {
              "url": order_path
              # "additionalProp2": Rails.env.production?,
              # "additionalProp3": "string"
            }
          }, {
            "item": 'Direction: %s' % [@order.shopper_address_additional_direction], # header of what is being
            "format": 'TEXT' # format - URL/TEXT - URL has to be a hyperlink#
          }, {
            "item": 'Notes: %s' % [@order.shopper_note.present? ? @order.shopper_note.to_s : 'NA'],
            "format": 'TEXT'
          }, {
            "item": 'Status: %s' % [@order.status],
            "format": 'TEXT',
            # "additionalValues": {
            #   "text": @order.status
            # }
          }, {
            "item": 'Payment Type: %s' % [@order.payment_type],
            "format": 'TEXT',
            # "additionalValues": {
            #   "text": @order.payment_type
            # }
          }, {
            "item": 'Vehicle: %s' % [@order.delivery_vehicle.present? && @order.delivery_vehicle || 'car'],
            "format": 'TEXT',
          }
        ]
      },
      "volume": {
        "value": @order.order_positions.where(was_in_shop: true).count, # total volume of the order in the unit of capacity - if order count is the capacity, value is 1#
        "unit": 'ITEM_COUNT' # unit to map - always ITEM_COUNT
      },
      "resources": [{ "name": 'order', "value": 1.0 }]
    }.to_json

    # puts params
    response = sendRequest(partner, 'put', '%s/client/%s/spmdtask/%s' % [partner.api_url, partner.user_name, @order.id], params)
    if response.status.to_i == 200 && (delivery_channel = DeliveryChannel.find_or_create_by(:name => 'Locus'))
      body = JSON(response.body)
      @order.delivery_channel_id = delivery_channel.id
      @order.card_detail = @order.card_detail.to_h.merge({ 'tracking_url' => body['taskGraph']['visits'][1]['trackLink'] }) rescue @order.card_detail
      @order.save
      @order.assign_locus_task
    end
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus Task Created' : 'Locus Task Failed', @order, response.body)
  end

  # ****Process orders in Batches using Locus OrderIQ****
  def batch_create_booking(partner)
    params = {
      "taskId": @order.id,
      "teamId": partner.api_key.present? && partner.api_key || 'dubai',
      "homebaseId": "RET#{@order.retailer_id}",
      # "skills": [@order.retailer.retailer_type == 2 && 'bike' || @order.delivery_vehicle.present? && @order.delivery_vehicle || 'car'],
      # "skills": [# skills are segregation - frozen to go to frozen vehicles - optional#
      #   # @order.retailer.retailer_type == 2 && 'bike' || @order.delivery_vehicle.present? && @order.delivery_vehicle || 'car'
      #   if @order.delivery_vehicle.present?
      #     @order.delivery_vehicle
      #   elsif @order.retailer.retailer_type == 2
      #     'bike'
      #   else
      #     'car'
      #   end
      # ],
      "orderDate": @order.created_at.to_date,
      "customFields": {
        "EGOrderStatus": @order.status,
        "EGOrderVehicle": @order.delivery_vehicle.to_s,
      },
      "taskType": 'DROP',
      "autoAssign": true,
      "visitName": @order.shopper_name,
      "contactPoint": { "name": @order.shopper_name,
                        "number": @order.shopper_phone_number.phony_normalized&.truncate(15)
      },
      "locationAddress": {

        "localityName": shopper_address.locality || shopper_address.administrative_area_level_1 || 'Dubai',
        "formattedAddress": shopper_address_detail,
        "subLocalityName": shopper_address.sublocality || shopper_address.locality || shopper_address.administrative_area_level_1 || 'Dubai',
        "city": shopper_address.administrative_area_level_1 || 'Dubai',
        "countryCode": 'AE',
        "locationType": 'CLIENT'
      },
      "latLng": {
        "lat": @order.shopper_address_latitude.to_f,
        "lng": @order.shopper_address_longitude.to_f
      },

      "slot": {
        "start": starting_time < Time.now.utc ? (Time.now + 5.minute).utc.iso8601 : starting_time,
        "end": latest_time
      },
      "transactionDuration": Integer(SystemConfiguration.find_by("key ~* 'locus.droptransactionduration'")&.value || 15).minute, # time to be spent at the customer location by driver#
      "amountTransaction": {
        "amount": {
          "amount": (@order.total_value.to_f + @order.service_fee.to_f + @order.delivery_fee.to_f + @order.rider_fee.to_f), # value to be transacted with the customer#
          "currency": 'AED' # always AED#
        },
        "exchangeType": payment_method # type of transaction - GIVE/COLLECT/PAID#
      },
      "appFields": { # pickup notes that will popup in the app as an array#
        "items": [
          {
            "item": "ORD##{@order.id}",
            "format": 'URL',
            "additionalValues": {
              "url": order_path
            }
          }, {
            "item": 'Direction: %s' % [@order.shopper_address_additional_direction], # header of what is being
            "format": 'TEXT' # format - URL/TEXT - URL has to be a hyperlink#
          }, {
            "item": 'Notes: %s' % [@order.shopper_note.present? ? @order.shopper_note.to_s : 'NA'],
            "format": 'TEXT'
          }, {
            "item": 'Status: %s' % [@order.status],
            "format": 'TEXT',
          }, {
            "item": 'Payment Type: %s' % [@order.payment_type],
            "format": 'TEXT',
          }, {
            "item": 'Vehicle: %s' % [@order.delivery_vehicle.present? && @order.delivery_vehicle || 'car'],
            "format": 'TEXT',
          }
        ]
      },
      "volume": {
        "value": @order.order_positions.where(was_in_shop: true).count,
        "unit": 'IC'
      },
      "resources": [{ "name": 'order', "value": 1.0 }]
    }.to_json

    response = sendRequest(partner, 'put', '%s/client/%s/order/%s' % [partner.api_url, partner.user_name, @order.id], params)
    if response.status.to_i == 200 && (delivery_channel = DeliveryChannel.find_or_create_by(:name => 'Locus'))
      body = JSON(response.body)
      @order.delivery_channel_id = delivery_channel.id
      # @order.card_detail = @order.card_detail.to_h.merge({ 'tracking_url' => body['taskGraph']['visits'][1]['trackLink'] }) rescue @order.card_detail
      @order.save
      # @order.assign_locus_task
    end
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus Batch Task Created' : 'Locus Batch Task Failed', @order, response.body)
  end

  def assign_booking(partner)
    params = {
      # "assignedUser": { #(for pre-defined assignment)
      #   "carrierClientId": "string",
      #   "userId": "string"
      # },
      "autoAssign": true # (true if autoassignment),
      # "notOptimal": false #(false if any assignment),
      # "dryRun": false #(true if you need to check for availability but not assign),
      # "currentUser": { #(for pre-defined assignment)
      #   "carrierClientId": "string",
      #   "userId": "string"
      # }
    }.to_json

    response = sendRequest(partner, 'post', '%s/client/%s/task/%s/assign' % [partner.api_url, partner.user_name, @order.id], params)
    Analytic.add_activity(response.status.to_i == 200 && !JSON(response.body)['assignedUser'].blank? ? 'Locus Task Assigned' : 'Locus Task Assigned Failed', @order, response.body)
    @order.update!(delivery_channel_id: DeliveryChannel.find_or_create_by(name: JSON(response.body)['assignedUser']['userId']).id) if !JSON(response.body)['assignedUser'].blank? rescue ''
    # if not assigned requeue the assign
    retry_in = Integer(SystemConfiguration.find_by("key ~* 'locus.retryAssignMinutes'")&.value || 10).minute
    notifyAfterNreTry = Integer(SystemConfiguration.find_by("key ~* 'locus.notifyAfterNreTry'")&.value || 10)
    reTryCount = Analytic.where(owner_id: @order.id, event_id: [65, 89]).count

    if JSON(response.body)['assignedUser'].blank? && !([2, 3, 4, 5].include? @order.status_id) && (Time.now < @order.estimated_delivery_at + 12.hours)
      Resque.enqueue_at(retry_in.from_now, PartnerIntegrationJob, @order.id, PartnerIntegration.integration_types[:locus_assign_order]) if reTryCount <= notifyAfterNreTry
      Slack::SlackNotification.new.send_order_not_assigned_notification(@order.id, !partner.api_key.blank? && partner.api_key || 'dubai') if @order.retailer&.retailer_group_id != 1 && reTryCount == notifyAfterNreTry
    end
  end

  def create_homebase(partner)
    retailer = partner.retailer
    raddress = Geocoder.search([retailer.latitude, retailer.longitude]).first
    params = [
      {
        "clientId": partner.user_name,
        "id": "RET#{partner.retailer_id}",
        "code": "RET#{partner.retailer_id}",
        "name": retailer.company_name,
        "status": 'ACTIVE',
        "type": 'HOMEBASE',
        "transactionDuration": Integer(SystemConfiguration.find_by("key ~* 'locus.picktransactionduration'")&.value || 10).minute, # time to be spent at the homebase location by driver#
        "teams": [
          {
            "clientId": partner.user_name,
            "teamId": !partner.api_key.blank? && partner.api_key || 'dubai'
          }
        ],
        "address": {
          "formattedAddress": '%s - %s' % [retailer.company_name, raddress&.formatted_address],
          "pincode": raddress&.postal_code,
          "city": raddress&.city || 'Dubai',
          "countryCode": raddress&.country_code
        },
        "latLng": {
          "lat": retailer.latitude,
          "lng": retailer.longitude
        }
      }
    ].to_json

    api_url = partner.api_url.sub('oms.', '')
    response = sendRequest(partner, 'post', '%s/client/%s/homebase-master?overwrite=true' % [api_url , partner.user_name], params)
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus HomeBase Updated' : 'Locus HomeBase Update Failed', retailer, response.body)
  end

  def cancel_booking(partner, cancellation_note)
    params = {
      "status": 'CANCELLED',
      "triggerTime": Time.now.utc.iso8601,
      "cancellationNotes": cancellation_note
    }.to_json

    response = sendRequest(partner, 'post', '%s/client/%s/task/%s/status' % [partner.api_url, partner.user_name, @order.id], params)
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus Task Cancelled' : 'Locus Task Cancellation Failed', @order, response.body)
  end

  #****Process orders in Batches using Locus OrderIQ****
  def batch_cancel_booking(partner, cancellation_note)
    params = {
      # "status": 'CANCELLED',
      # "triggerTime": Time.now.utc.iso8601,
      # "cancellationNotes": cancellation_note
    }.to_json

    response = sendRequest(partner, 'put', '%s/client/%s/order/%s/cancel' % [partner.api_url, partner.user_name, @order.id], params)
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus Batch Task Cancelled' : 'Locus Batch Task Cancellation Failed', @order, response.body)
  end

  #****Process orders in Batches using Locus OrderIQ****
  def reschedule_order(partner)
    params = {
      "customerRescheduleRequest": {
        "rescheduleDate": @order.created_at.to_date,
        "rescheduleSlot": {
          "start": starting_time < Time.now.utc ? (Time.now + 5.minute).utc.iso8601 : starting_time,
          "end": latest_time
        }
      }
    }.to_json
    response = sendRequest(partner, 'post', '%s/client/%s/order/%s/reschedule' % [partner.api_url, partner.user_name, @order.id], params)
    if response.status.to_i == 200 && (delivery_channel = DeliveryChannel.find_or_create_by(:name => 'Locus'))
      body = JSON(response.body)
      # @order.delivery_channel_id = delivery_channel.id
      # @order.card_detail = @order.card_detail.to_h.merge({ 'tracking_url' => body['taskGraph']['visits'][1]['trackLink'] }) rescue @order.card_detail
      # @order.save
      # @order.assign_locus_task
    end
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus Task Rescheduled' : 'Locus Task Rescheduled Failed', @order, response.body)
  end

  def update_customfields(partner)
    params = {
      "customFields": {
        "EGOrderStatus": @order.status
      }
    }.to_json

    response = sendRequest(partner, 'post', '%s/client/%s/task/%s/custom-fields' % [partner.api_url, partner.user_name, @order.id], params)
    # Analytic.add_activity(response.status.to_i == 200 ? "Locus Task Cancelled" : "Locus Task Cancellation Failed" , @order, response.body)
  end

  #  *** OIQ Locus batch update custom fields ***
  def update_egorder_status(partner)
    params = {
      "patchBody": {
        "customProperties": {
          "EGOrderStatus": @order.status
        }
      }
    }.to_json
    response = sendRequest(partner, 'post', '%s/client/%s/order/%s/update' % [partner.api_url, partner.user_name, @order.id], params)
    # Analytic.add_activity(response.status.to_i == 200 ? "EG Order Status Updated" : "EG Order Status Update Failed" , @order, response.body)
  end

  def update_amount(partner)
    params = {
      "amount": {
        "amount": @order.final_amount.to_f,
        "currency": 'AED'
      },
      "exchangeType": payment_method # type of transaction - GIVE/COLLECT/PAID#
    }.to_json

    response = sendRequest(partner, 'post', '%s/client/%s/task/%s/visit/%s/amount' % [partner.api_url, partner.user_name, @order.id, 'customer'], params)
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus Task Update Amount' : 'Locus Task Update Amount Failed' , @order, response.body)
  end

  def locus_post_update_amount(partner)
    params = {
      "patchBody": {
        "amountTransaction": {
          "amount": {
            "amount": @order.final_amount.to_f,
            "currency": 'AED'
          },
          "exchangeType": 'COLLECT'
        }
      }
    }.to_json

    response = sendRequest(partner, 'post', '%s/client/%s/order/%s/update' % [partner.api_url, partner.user_name, @order.id, 'customer'], params)
    Analytic.add_activity(response.status.to_i == 200 ? 'Locus Batch Task Update Amount' : 'Locus Batch Task Update Amount Failed' , @order, response.body)
  end

  def sendRequest(partner, method, url_path, params)
    # api_key = partner.api_key || ENV['LOCUSSH_API_KEY']
    # host_url = partner.api_url || ENV['LOCUSSH_URL']
    user_name = partner.user_name || ENV['LOCUSSH_USERNAME']
    password = partner.password || ENV['LOCUSSH_PASSWORD']

    client = HTTPClient.new
    client.set_auth(url_path, user_name, password)
    headers = {
      'Authorization' => "Basic #{Base64.encode64("#{user_name}:#{password}").gsub("\n", '')}",
      'Content-Type': 'application/json'
    }
    client.send(method, url_path, params, headers)
  end

  def payment_method
    case @order.payment_type_id
    when 1
      'COLLECT'
    when 2
      'COLLECT'
    else
      'NONE'
    end
  end

  def shopper_address_detail
    case @order.shopper_address_type_id
    when 0
      address = [@order.shopper_address_apartment_number, @order.shopper_address_floor, @order.shopper_address_building_name, @order.shopper_address_street, @order.shopper_address_name, @order.shopper_address_area]
    when 1
      address = [@order.shopper_address_house_number, @order.shopper_address_street, @order.shopper_address_name, @order.shopper_address_area]
    else
      address = [@order.shopper_address_apartment_number, @order.shopper_address_floor, @order.shopper_address_building_name, @order.shopper_address_street, @order.shopper_address_name, @order.shopper_address_area]
    end
    address = address.reject(&:blank?).uniq
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
    slot_diff = @order.delivery_slot_id && @order.delivery_slot && (@order&.delivery_slot&.end.to_i - @order&.delivery_slot&.start.to_i) || 0
    if ((@order.estimated_delivery_at + slot_diff) - Time.now) > 30.minutes
      (@order.estimated_delivery_at + slot_diff).utc.iso8601
    else
      (Time.now + 30.minute).utc.iso8601
    end
  end

  def starting_time
    @order.delivery_slot_id && @order.estimated_delivery_at.utc.iso8601 || @order.created_at.utc.iso8601
  end

  def order_path
    "https://el-grocer-#{Rails.env.production? ? 'admin' : 'staging-dev'}.herokuapp.com/admin/orders/#{@order.id}"
  end
end
