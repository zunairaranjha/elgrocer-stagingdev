class Products::Base < ActiveInteraction::Base

  private

  def product_exists
    errors.add(:product_id, 'Product does not exist') unless product.present?
  end

end
