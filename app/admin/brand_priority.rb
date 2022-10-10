# frozen_string_literal: true

ActiveAdmin.register_page "Brand Priority" do
  menu parent: "Brands"

  content do
    columns do
        column do
          render partial: "form", locals: {brands: Brand.order(:priority)}
        end
        column do
          panel 'Click to set priority Category Wise' do
            pcats = Category.where('parent_id IS NULL')
            ul do
              pcats.each do |cat|
                li link_to(cat.name, admin_brand_priority_category_brands_path(:id => cat.id))
                ul do
                  cat.subcategories.each do |subcat|
                    li link_to(subcat.name, admin_brand_priority_category_brands_path(:id => subcat.id))
                  end
                end
              end
            end
          end
        end
    end
  end

  page_action :update, method: :post do
    params[:brands].each_pair do |brand_id, position|
      Brand.find(brand_id).update_column(:priority, position.to_i)
    end
    redirect_to admin_brand_priority_path, notice: "Brands updated."
  end

  page_action :category_brands do
    cat = Category.find(params[:id])
    if cat.parent_id.blank?
      #@brands = Category.find(params[:id]).brands.sort_by { |hsh| hsh[:priority]}
      @brands = Brand.joins(:categories).distinct.where(:categories => {:id => params[:id]}).order(:priority)
    else
      #@brands = []
      #cat.subcategories.each do |scat|
      #  @brands.concat(scat.brands)
      #end
      #@brands.sort_by { |hsh| hsh[:priority]}
      @brands = Brand.joins(:subcategories).distinct.where(:categories => {:id => params[:id]}).order(:priority)
    end
    #@brands = Brand.limit(10).order(:priority)
  end
end
