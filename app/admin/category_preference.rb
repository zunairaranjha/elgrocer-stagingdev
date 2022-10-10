# frozen_string_literal: true

ActiveAdmin.register_page "Category Preference" do
  menu parent: "Collections"

  content do
    l_module = DashboardService
    columns do
        column do
          panel 'Category Ordering' do
            render partial: "form", locals: {categories: Category.where('parent_id IS NULL').order(:priority)}
          end
        end
        column do
          panel 'Sub Category Ordering' do
            results = l_module.get_all_categories
            ul do
              results.each do |res|
                li link_to(res.name, subcategory_preference_path(res))
              end
            end
          end
        end
    end
  end

  controller do
    def add_positions
      params[:categories].each_pair do |category_id, position|
        Category.find(category_id).update_column(:priority, position.to_i)
      end
      redirect_to admin_category_preference_path, notice: "order updated"
    end
    def sub_categories
      @categories = Category.find(params[:id]).subcategories.order(:priority)
    end
  end

end
