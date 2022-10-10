module RetailerOpenHours
  extend ActiveSupport::Concern

  included do
    scope :in_opened_hours, -> {
      where(
        "retailer_opening_hours.open < #{Time.now.seconds_since_midnight}
          AND retailer_opening_hours.close > #{Time.now.seconds_since_midnight}
          AND retailer_opening_hours.day = #{Time.now.wday + 1}"
      )
    }
  end
end
