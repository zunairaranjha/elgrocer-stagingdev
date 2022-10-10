# frozen_string_literal: true

class RetailerType < ApplicationRecord
  attr_accessor :name_en, :name_ar, :description_en, :description_ar

  has_one :image, as: :record, dependent: :destroy
  has_many :retailers, foreign_key: 'retailer_type'

  accepts_nested_attributes_for :image, allow_destroy: true

  def name
    if (I18n.locale != :en) && I18n.available_locales.include?(I18n.locale)
      name = self.send("name_#{I18n.locale.to_s}")
    end
    name.present? && name || self.send('name_en')
  end

  def name_en
    translations['name_en']
  end

  def name_ar
    translations['name_ar']
  end

  def description
    if (I18n.locale != :en) && I18n.available_locales.include?(I18n.locale)
      value = self.send("description_#{I18n.locale.to_s}")
    end
    value.present? && value || self.send('description_en')
  end

  def description_en
    translations['description_en']
  end

  def description_ar
    translations['description_ar']
  end

end
