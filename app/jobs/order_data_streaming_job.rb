class OrderDataStreamingJob < ActiveJob::Base
  queue_as :kafka_stream

  def perform(order, previous_status)
    Kafka::CloudKarafka.new.produce_kafka_msg(order, previous_status)
  end

end
