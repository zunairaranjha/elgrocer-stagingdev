class Categories::Create < Categories::Base

  integer :category_id, default: nil
  string :category_name
  string :subcategory_name

  def execute
    create_category_and_subcategory
  end

  private


  def create_category_and_subcategory
    if category_id
      category = Category.find(category_id)
    elsif Category.find_by(name: category_name)
      category = Category.find_by(name: category_name)
    else
      category = Category.create!(name: category_name)
    end

    if Category.find_by(name: subcategory_name)
      subcategory = Category.find_by(name: subcategory_name)
    else
      subcategory = Category.create!(name: subcategory_name)
    end

    subcategory.parent_id = category.id
    subcategory.save!
    category
  end

end