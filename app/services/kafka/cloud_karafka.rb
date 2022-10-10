# frozen_string_literal: true

require 'json'

class Kafka::CloudKarafka

  def initialize(topic = nil)
    @topic = topic || ENV['CLOUDKARAFKA_TOPIC']
    @rdkafka = Rdkafka::Config.new({
                                     "bootstrap.servers": ENV['CLOUDKARAFKA_BROKERS'],
                                     "group.id": 'cloudkarafka-example',
                                     "sasl.username": ENV['CLOUDKARAFKA_USERNAME'],
                                     "sasl.password": ENV['CLOUDKARAFKA_PASSWORD'],
                                     "security.protocol": 'SASL_SSL',
                                     "sasl.mechanisms": 'SCRAM-SHA-256'
                                   })
  end

  def produce_kafka_msg(order, previous_status)
    key = "#{order.class.name}##{order.id}"
    order_positions = order.order_positions
    order_substitutions = order.order_substitutions
    if order.language == 'ar'
      order_positions.each do |positions|
        positions.product_id = positions.product_id || positions.product_proposal_id
        unless positions.product_proposal_id.to_i.positive?
          product = Product.find_by(id: positions.product_id)
          positions.product_name = product.name
          positions.product_description = product.description
          positions.product_size_unit = product.size_unit
        end
      end
      order_substitutions.each do |substitutions|
        substitutions.substituting_product_id = substitutions.substituting_product_id || substitutions.product_proposal_id
        unless substitutions.product_proposal_id || substitutions.substitute_detail.blank?
          product = Product.find_by(id: substitutions.product_id)
          os = JSON(substitutions.substitute_detail)
          os.merge!({ 'product_name' => product.name, 'product_size_unit' => product.size_unit, 'product_description' => product.description })
          substitutions.substitute_detail = os.to_json
        end
      end
    end

    payload = order.as_json
    payload[:order_positions] = order_positions.as_json
    payload[:order_collection_detail] = order.order_collection_detail.as_json
    payload[:promotion_code_realization] = order.promotion_code_realization.as_json
    payload[:promotion_code] = order.promotion_code_realization&.promotion_code.as_json
    payload[:delivery_slot] = order.delivery_slot.as_json
    payload[:retailer_delivery_zone] = order.retailer_delivery_zone.as_json
    payload[:previous_status] = previous_status
    payload[:order_substitutions] = order_substitutions.as_json

    produce_msg(@topic, key, 0, payload.to_json)
  end

  def produce_finance_event_kafka_msg(order, event, response)
    key = "#{order.class.name}##{order.id}"
    payload = {
      order_id: order.id,
      created_at: order.created_at,
      retailer_id: order.retailer_id,
      vat: order.vat,
      event: event,
      online_pmt_charge: order.retailer.retailer_group&.online_payment_charge,
      event_response: response,
      event_log_time: Time.now
    }

    partition = event =~ /Adyen/ ? 2 : 1
    produce_msg(@topic, key, partition, payload.to_json)
  end

  def send_kafka_message(owner, event, params, response, key = nil)
    payload = {}
    key ||= "#{owner.class.name}##{owner.id}"
    payload[:event] = event
    payload[:time] = Time.now
    payload[:params] = params
    payload[:response] = response
    produce_msg(@topic, key, 2, payload.to_json)
  end

  # Method for sending analytics related message to Kafka
  def send_kafka_analytic_message(owner, event, detail, key = nil)
    payload = {}
    # detail = {}
    key ||= "#{owner.class.name}##{owner.id}"

    # Assign response and param details to details object
    # detail[:response] = response ? response.as_json : nil
    # detail[:params] = params ? params.as_json : nil

    # Assign details object to detail key and other data
    payload[:detail] = detail.as_json
    payload[:event_id] = event.id.to_i
    payload[:event_name] = event.name.to_s
    payload[:owner_id] = owner.id.to_i
    payload[:owner_type] = owner.class.name.to_s
    payload[:time] = Time.now

    # Here we are using different topics for different events
    # That's why we do not need partition to be specified.
    produce_msg(@topic, key, nil, payload.to_json)
  end

  def produce_msg(topic, key, partition, payload)
    producer = @rdkafka.producer
    producer.produce(
      topic: topic,
      payload: payload,
      key: key,
      partition: partition
    ).wait
    producer.close
  end

end
