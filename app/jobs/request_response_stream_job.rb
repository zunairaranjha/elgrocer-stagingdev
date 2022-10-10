class RequestResponseStreamJob < ActiveJob::Base
  queue_as :kafka_stream

  def perform(topic: nil, key: nil, event: nil, request: nil, response: nil, owner: nil)
    Kafka::CloudKarafka.new(topic).send_kafka_message(owner, event, request, response, key)
  end

end

