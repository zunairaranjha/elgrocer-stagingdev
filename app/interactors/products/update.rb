class Products::Update < Products::Base

  integer :product_id
  string :name, default: nil
  string :description, default: nil
  string :barcode, default: nil
  string :size_unit, default: nil
  integer :shelf_life, default: nil
  string :brand_name, default: nil
  string :country_alpha2, default: nil
  boolean :is_local, default: nil
  integer :subcategory_id, default: nil

  validate :product_exists

  def execute
    update!
    #product.__elasticsearch__.update_document
    product.reload
  end

  private

  def product
    @product ||= Product.unscoped.find_by({id: product_id})
  end

  def update_params
    params = { }
    params[:name] = name unless name.nil?
    params[:description] = description unless description.nil?
    params[:barcode] = barcode unless barcode.nil?
    params[:size_unit] = size_unit unless size_unit.nil?
    params[:shelf_life] = shelf_life unless shelf_life.nil?
    params[:is_local] = is_local unless is_local.nil?
    params
  end

  def update!
    product.update!(update_params)
    product.add_brand(brand_name)
    product.add_category(subcategory_id)
    if country_alpha2
      product.update_country(country_alpha2)
    end
    product
  end

end
