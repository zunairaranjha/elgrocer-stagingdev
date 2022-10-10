class PromotionCodeDecorator < Draper::Decorator

  def status
    if model.start_data.present? && (model.start_date > Time.zone.now)
      'inactive'
    else
      'active'
    end
  end
end
