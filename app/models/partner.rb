class Partner < ApplicationRecord
  after_save :cache_update
  def self.create_method(names)
    names.each do |actions|
      define_method(actions) do
        self.config[actions]
      end
    end    
  end

  def smile_data
    {
      "earning": self.config["earning"].to_f,
      "burning": self.config["burning"].to_f,
      "allow_retry": self.config["allow_retry"].to_i,
      "retry_interval": self.config["retry_interval"],
      "retry_interval_delay_multiplier": self.config["retry_interval_delay_multiplier"].to_f
    }
  end


  def cache_update
    if %w[smile_data].include? self.name
      Redis.current.set self.name, self.config.to_json
    end
  end

  def self.get_key_value(key)
    value = Redis.current.get(key)
    return value if value

    value ||= Partner.find_by(name: key)&.config.to_json
    Redis.current.set key, value
    value
  end

end
