class OrderFeedback < ActiveRecord::Base
  belongs_to :order, optional: true
  has_one :shopper, through: :order
  has_one :retailer, through: :order
  has_one :picker, through: :order

  # ["id", "order_id", "delivery", "speed", "accuracy", "price", "comments", "created_at", "updated_at"]

  # How was your delivery? 
  #  1-5 stars
  # When did your delivery arrive? 
  #  1) Early 2) On Time 3) Late 4) Still Waiting
  # Are you satisfied with the quality of the items our picker selected for you?
  #  1) Unsatisfied 2) Somewhat unsatisfied 3) Somewhat satisfied 4) Satisfied
  # How would you rate the overall cost of grocery delivery?
  #  1) Cheaper 2) About the same 3) More expensive
  # Additional feedback
  #  text/comments
  # enum delivery: ['*', '**', '***', '****', '*****'] #, _prefix: :delivery
  enum speed: { early: 1, on_time: 2, late: 3, still_waiting: 4, excellent: 5 } #, _prefix: :speed
  enum accuracy: { unsatisfied: 1, somewhat_unsatisfied: 2, somewhat_satisfied: 3, satisfied: 4, happy: 5 }
  enum price: { cheaper: 1, about_the_same: 2, more_expensive: 3 }

  after_commit on: [:create] do
    ::SlackNotificationJob.perform_later(self.order_id, 12)
    self.order.update(feedback_status: "feedback_received")
  end

  def delivery_stars
    # '*****'.first(delivery || 0)
    "#{'★★★★★'.first(delivery.to_i) + '☆☆☆☆☆'.last(5 - delivery.to_i)}"
  end

  def self.Questions
    {
      delivery: 'How was your delivery?',
      speed: 'When did your delivery arrive?',
      accuracy: 'Are you satisfied with the quality of the items our picker selected for you?',
      price: 'How would you rate the overall cost of grocery delivery?',
      comments: 'Additional feedback'
    }
  end

  def shopper
    order.try(:shopper)
  end

end
