class Ingredient < ActiveRecord::Base
  attr_accessor :qty_en, :qty_ar, :qty_unit_en, :qty_unit_ar
  belongs_to :recipe, optional: true, touch: true
  belongs_to :product, optional: true

  def qty_en
    translations["qty_en"]
  end

  def qty_ar
    translations["qty_ar"]
  end

  def qty
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      qty = self.send("qty_#{I18n.locale.to_s}")
    end
    qty.present? && qty || self.send("qty_en")
  end

  def qty_unit_en
    translations["qty_unit_en"]
  end

  def qty_unit_ar
    translations["qty_unit_ar"]
  end

  def qty_unit
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      qty_unit = self.send("qty_unit_#{I18n.locale.to_s}")
    end
    qty_unit.present? && qty_unit || self.send("qty_unit_en")
  end

end
