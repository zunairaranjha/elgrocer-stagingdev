class SmilesTransactionLog < ApplicationRecord
  ############# Associations ##############
  belongs_to :order

  def self.add_activity(event, req, res, order, formula, transaction_amount)
    stl = SmilesTransactionLog.new
    stl.event = event
    stl.transaction_id = res['memberActivityResponse']['transactionId'] rescue res['rollbackResponse']['transactionId']
    stl.transaction_ref_id = res['memberActivityResponse']['transactionRefId'] rescue res['rollbackResponse']['transactionId']
    stl.order_id = order.id
    stl.shopper_id = order.shopper_id
    stl.conversion_rule = formula
    stl.transaction_amount = transaction_amount
    stl.details = { request: req, response: res }
    stl.save
    # Send smiles analytics message.
    SmilesTransactionLog.send_kafka_analytics(order, event, stl)
  end

  # Method to send Kafka Smiles Analytics Messages
  def self.send_kafka_analytics(owner, event_name, detail = nil)
    if owner.present? && event_name.present?

      # Create event if not exists
      event = Event.find_or_create_by(name: event_name)
      # Get Kafka topics..
      topics = SystemConfiguration.get_key_value('kafka_analytics_topics')
      # Parse and get single kafka topic..
      topic = JSON.parse(topics)["smiles_analytics_topic"]
      # Send kafka analytics event..
      AnalyticsKafkaStreamJob.perform_later(topic, owner, event, detail)
    else
      nil
    end
  end

end
