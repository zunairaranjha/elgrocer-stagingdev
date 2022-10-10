# frozen_string_literal: true

class Analytic < ActiveRecord::Base

  belongs_to :owner, optional: true, polymorphic: true
  belongs_to :event, optional: true

  validates_presence_of :owner, :event_id

  default_scope -> { where('analytics.created_at > ?', ANALYTICS_START_DATE) }

  def self.add_activity(name, owner, detail = nil)
    event = Event.find_or_create_by(name: name)
    begin
      Analytic.create(owner: owner, event_id: event.id, detail: detail) if owner.present? && event.present?
    rescue StandardError
      nil # Ignored
    end
    Analytic.send_kafka_analytics(owner, event, detail)
  end

  def self.post_activity(name, owner, detail: nil, date_time_offset: nil)
    event = Event.find_or_initialize_by(name: name)
    event.date_time_offset = date_time_offset
    event.save
    begin
      if owner.present? && event.present?
        Analytic.create(owner: owner, event_id: event.id, detail: detail,
                        date_time_offset: date_time_offset)
      end
    rescue StandardError
      nil # Ignored
    end
    Analytic.send_kafka_analytics(owner, event, detail)
  end

  # Method to send Kafka Analytics Messages
  def self.send_kafka_analytics(owner, event, detail = nil)
    if owner.present? && event.present?
      # Get Kafka topic..
      topic = get_kafka_topic(owner, event)
      # Send kafka analytics event..
      AnalyticsKafkaStreamJob.perform_later(topic, owner, event, detail) if topic
    end
  end

  # Method to get Kafka Topic for Analytics Messages
  def self.get_kafka_topic(owner, event)
    owner_name = owner.class.name.to_s.downcase

    owner_name = owner_name == 'order' && event.name.to_s.include?('Adyen') ? 'adyen' : owner_name

    # Pattern (Hash): {"adyen_analytics_topic" => "mvfw1byk-default"}
    topics = SystemConfiguration.get_key_value('kafka_analytics_topics')

    # Convert string hash to hash object..
    topics.blank? ? ENV['GENERAL_ANALYTIC_TOPIC'] : JSON.parse(topics)["#{owner_name}_analytics_topic"]
  end

end
