class Color < ActiveRecord::Base
  def name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("name_#{I18n.locale.to_s}") 
    end
    value || read_attribute(:name)
  end
end
