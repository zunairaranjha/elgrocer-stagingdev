describe API::V1::Products::Update, type: :request do

  let!(:retailer) do
    FactoryBot.create(:retailer)
  end
  let!(:product) do
    FactoryBot.create(:product)
  end
  let!(:brand) do
    FactoryBot.create(:brand, {
      name: "Brand"
      }
    )
  end

  let!(:parent_category) do
    FactoryBot.create(:category, {
        name: 'Food'
      })
  end

  let!(:category) do
    FactoryBot.create(:category, {
        name: 'GoodFood',
        parent_id: parent_category.id
      })
  end

  let(:params_product1) {
    {
      name: "New name",
      description: "Description of product1",
      barcode: "555444333222",
      is_local: true,
      # shelf_life: 35,
      size_unit: "40 ml",
      brand_name: "Brand",
      # country_alpha2: "US",
      subcategory_id: category.id
    }
  }
  let(:params_product2) {
    {
      name: "New name",
      description: "Description of product2",
      barcode: "555444333222",
      is_local: true,
      shelf_life: 35,
      size_unit: "40 ml",
      brand_name: "Brand NON-EXIST",
      country_alpha2: "US",
      subcategory_id: category.id
    }
  }
  #before :each do
  #  Product.__elasticsearch__.create_index! force: true
  #  Product.__elasticsearch__.import
  #end


  describe 'PUT /products/update - brand exist, categories non-exist' do
    subject(:request_response) {
      put '/api/v1/products/update', params: params_product1.merge({product_id: product.id}), headers: {"Authentication-Token" => retailer.authentication_token , "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) {JSON.parse(request_response.body)}

      # it 'contains data of product with all requested attributes' do
      #   res = returned_orders
      #   res_data = res['data']
      #   product_data = res_data['product']
      #   product_country = product_data['country']
      #   product_brand = product_data['brand']
      #   product_category = product_data['categories'][0]
      #   product_category_child = product_category['children'][0]
      #
      #   expect(res['messages']).to be_nil
      #   expect(res['status']).to eq "success"
      #   expect(res['data']).to be_a Hash
      #
      #   expect(product_data).to be_a Hash
      #   expect(product_data['id']).to eq product.id
      #   expect(product_data['barcode']).to eq params_product1[:barcode]
      #   expect(product_data['size_unit']).to eq params_product1[:size_unit]
      #   expect(product_data['shelf_life']).to eq product.shelf_life
      #
      #   expect(product_country['name']).to eq "Poland"
      #   expect(product_country['alpha2']).to eq "PL"
      #
      #   expect(product_category['name']).to eq parent_category.name
      #
      #   expect(product_category_child['name']).to eq category.name
      #
      #   expect(product_brand['name']).to eq params_product1[:brand_name]
      # end
    end
  end

  describe 'PUT /products/update - brand non-exist, categories exist' do
    subject(:request_response) {
      put '/api/v1/products/update', params: params_product2.merge({product_id: product.id}), headers: {"Authentication-Token" => retailer.authentication_token , "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) {JSON.parse(request_response.body)}

      # it 'contains data of product with all requested attributes' do
      #   res = returned_orders
      #   res_data = res['data']
      #   product_data = res_data['product']
      #   product_country = product_data['country']
      #   product_brand = product_data['brand']
      #   product_category = product_data['categories'][0]
      #   product_category_child = product_category['children'][0]
      #
      #   expect(res['messages']).to be_nil
      #   expect(res['status']).to eq "success"
      #   expect(res['data']).to be_a Hash
      #
      #   expect(product_data).to be_a Hash
      #   expect(product_data['id']).to eq product.id
      #   expect(product_data['barcode']).to eq params_product2[:barcode]
      #   expect(product_data['size_unit']).to eq params_product2[:size_unit]
      #   expect(product_data['shelf_life']).to eq params_product2[:shelf_life]
      #
      #   expect(product_country['name']).to eq "United States of America"
      #   expect(product_country['alpha2']).to eq "US"
      #
      #   expect(product_category['name']).to eq parent_category.name
      #
      #   expect(product_category_child['name']).to eq category.name
      #
      #   expect(product_brand['name']).to eq params_product2[:brand_name]
      # end
    end
  end
end
