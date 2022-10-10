describe API::V1::Categories::ShopperCategories, type: :request do
  # let!(:retailer) { create(:retailer) }
  # let(:token) { { "Authentication-Token" => retailer.authentication_token } }
  #
  # let!(:retailer2) { create(:retailer) }
  #
  # let!(:shopper) do
  #   FactoryBot.create(:shopper)
  # end
  #
  # let!(:category) do
  #   FactoryBot.create(:category, name: "New category")
  # end
  #
  # let!(:category1) { create(:category, { name: "New empty category" }) }
  # let!(:category2) { create(:category, { name: "New 22empty category" }) }
  # let!(:subcategory1) { create(:category, { name: "New subcategory", parent_id: category.id }) }
  # let!(:subcategory2) { create(:category, { name: "Second new subcat", parent_id: category.id }) }
  # let!(:subcategory3) { create(:category, { name: "Third new subcat", parent_id: category2.id }) }
  # let!(:subcategory4) { create(:category, { name: "fourth new subcat", parent_id: category2.id }) }
  #
  # let!(:brand1) { create(:brand) }
  # let!(:product1) { create(:product, brand_id: brand1.id) }
  # let!(:product_subcategory1) {
  #   create(:product_category, category_id: subcategory1.id, product_id: product1.id)
  # }
  # let!(:brand2) { create(:brand) }
  # let!(:product2) { create(:product, brand_id: brand2.id) }
  # let!(:product_subcategory2) do
  #   create(:product_category, category_id: subcategory2.id, product_id: product2.id)
  # end
  # let!(:brand3) { create(:brand) }
  # let!(:product3) { create(:product, brand_id: brand3.id) }
  # let!(:product_subcategory3) do
  #   create(:product_category, category_id: subcategory3.id, product_id: product3.id)
  # end
  # let!(:product4) { create(:product, brand_id: brand3.id) }
  # let!(:product_subcategory4) do
  #   create(:product_category, category_id: subcategory4.id, product_id: product4.id)
  # end
  # let!(:shop1) { create(:shop, product_id: product1.id, retailer_id: retailer.id) }
  # let!(:shop2) { create(:shop, product_id: product2.id, retailer_id: retailer2.id) }
  # let!(:shop3) { create(:shop, product_id: product3.id, retailer_id: retailer2.id) }
  # let!(:shop4) { create(:shop, product_id: product4.id, retailer_id: retailer2.id) }
  #
  # let(:params) { { limit: 2, offset: 0, retailer_id: retailer.id } }

  # describe 'GET /categories/shopper/tree' do
  #   subject(:request_response) {
  #     get '/api/v1/categories/shopper/tree', params, token
  #     response
  #   }
  #   it { expect(subject.status).to eq 200 }
  #
  #   describe 'returned json' do
  #     subject(:returned_data) {JSON.parse(request_response.body)}
  #
  #     it 'contains data of product with all requested attributes' do
  #       res = returned_data
  #       res_data = res['data']
  #
  #       expect(res['status']).to eq "success"
  #       expect(res['messages']).to be_nil
  #       expect(res['data']).to be_a Hash
  #       expect(res_data['categories'].size).to eq 1
  #       expect(res_data['next']).to eq true # There is a bug here we should address
  #     end
  #   end
  # end
  #
  # describe 'GET /categories/shopper/tree' do
  #   let(:params) {  { limit: 2, offset: 0, retailer_id: retailer.id, parent_id: category.id } }
  #   subject(:request_response) {
  #     get '/api/v1/categories/shopper/tree', params, token
  #     response
  #   }
  #   it { expect(subject.status).to eq 200 }
  #
  #   describe 'returned json' do
  #     subject(:returned_data) {JSON.parse(request_response.body)}
  #
  #     it 'contains data of product with all requested attributes' do
  #       res = returned_data
  #       res_data = res['data']
  #
  #       expect(res['messages']).to be_nil
  #       expect(res['status']).to eq "success"
  #
  #       expect(res['data']).to be_a Hash
  #       expect(res_data['categories'].size).to eq 1
  #       expect(res_data['next']).to eq false
  #     end
  #   end
  # end
end
