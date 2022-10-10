class AnalyticsKafkaStreamJob < ActiveJob::Base
  queue_as :kafka_stream

  def perform(topic = nil, owner = nil, event = nil, detail = nil, key = nil)
    Kafka::CloudKarafka.new(topic).send_kafka_analytic_message(owner, event, detail, key)
  end
end