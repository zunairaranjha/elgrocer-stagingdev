class Products::Show < ActiveInteraction::Base
  string :barcode

  def execute
    product = product_local
    if not product
      product = product_non_local
    end
    product
  end

  private

  def product_local
    product ||= Product.unscoped.find_by(barcode: barcode)
  end

  def product_non_local
    product = Product.create( {
      barcode: barcode,
      is_local: false
    })
    # product.create_from_base
    product
  end

end