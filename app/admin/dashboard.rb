# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  # content title: proc { I18n.t('active_admin.dashboard') } do
  #   # Here is an example of a simple dashboard with columns and panels.
  #   l_module = DashboardService
  #
  #   columns do
  #     column do
  #       panel 'Basket Size' do
  #         ul do
  #           li 'Biggest Basket: ' + number_with_precision(l_module.top_basket_size.to_f.round(2), :precision => 2)
  #           li 'Smallest Basket: ' + number_with_precision(l_module.bottom_basket_size.to_f.round(2), :precision => 2)
  #           li 'Average Basket: ' + number_with_precision(l_module.avarage_basket_size.to_f.round(2), :precision => 2)
  #         end
  #       end
  #     end
  #     column do
  #       panel 'Basket price' do
  #         ul do
  #           li 'Biggest Basket: ' + number_with_precision(l_module.top_basket_price.to_f.round(2), :precision => 2)
  #           li 'Smallest Basket: ' + number_with_precision(l_module.bottom_basket_price.to_f.round(2), :precision => 2)
  #           li 'Average Basket: ' + number_with_precision(l_module.avarage_basket_price.to_f.round(2), :precision => 2)
  #         end
  #       end
  #     end
  #   end
  #   columns do
  #     column do
  #       panel 'Top 10 products' do
  #         results = l_module.top_10_products
  #         ul do
  #           results.each do |res|
  #             li link_to(res.name, admin_product_path(res))
  #           end
  #         end
  #       end
  #     end
  #     column do
  #       panel 'Top 10 retailers' do
  #         results = l_module.top_10_retailers
  #         ul do
  #           results.each do |res|
  #             li link_to(res.company_name, admin_retailer_path(res))
  #           end
  #         end
  #       end
  #     end
  #   end
  #   columns do
  #     column do
  #       panel 'App statistics' do
  #         ul do
  #           li 'Amount of products in shops: ' + l_module.total_number_of_products
  #           li 'Total commissions collected: ' + l_module.total_income.to_s
  #           li 'Total commissions collected in this month: ' + l_module.current_month_total_income.to_s
  #         end
  #       end
  #     end
  #   end
  # end # content
end
