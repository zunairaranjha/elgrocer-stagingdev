class ShopProductLog < ActiveRecord::Base
	belongs_to :owner, optional: true, polymorphic: true

  def self.add_activity(name, owner)
    begin
      event = Event.find_or_create_by(:name => name)
      Analytic.create(:owner => owner, :event_id => event.id) if (owner.present? && event.present?)
    rescue => e
    end
  end


end

