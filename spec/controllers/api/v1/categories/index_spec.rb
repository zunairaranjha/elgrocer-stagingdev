describe API::V1::Categories::Index, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer, {
      is_opened: true,
      is_active: true
    })
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') })
  end

  let!(:category) do
    FactoryBot.create(:category, {
      name: "New category"
    }
    )
  end

  let!(:category1) do
    FactoryBot.create(:category, {
      name: "New empty category"
    }
    )
  end

  let!(:subcategory1) do
    FactoryBot.create(:category, {
      name: "New subcategory",
      parent_id: category.id
    }
    )
  end

  let!(:subcategory2) do
    FactoryBot.create(:category, {
      name: "Second new subcategory",
      parent_id: category.id
    }
    )
  end

  let!(:brand1) do
    FactoryBot.create(:brand)
  end

  let!(:product1) do
    FactoryBot.create(:product, {
      brand_id: brand1.id
    }
    )
  end

  let!(:product_subcategory1) do
    FactoryBot.create(:product_category, {
      category_id: subcategory1.id,
      product_id: product1.id
    })
  end

  let!(:brand2) do
    FactoryBot.create(:brand)
  end

  let!(:product2) do
    FactoryBot.create(:product, {
      brand_id: brand2.id
    }
    )
  end

  let!(:product_subcategory2) do
    FactoryBot.create(:product_category, {
      category_id: subcategory2.id,
      product_id: product2.id
    })
  end

  let!(:shop1) do
    FactoryBot.create(:shop, {
      product_id: product1.id,
      retailer_id: retailer.id
    })
  end

  describe 'GET /categories' do
    subject(:request_response) {
      get '/api/v1/categories', params: { limit: 5, offset: 0 }, headers: { "Authentication-Token" => retailer.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']['categories']
        is_next = res['data']['next']
        expect(res['status']).to eq "success"
        expect(res['messages']).to be_nil
        expect(res['data']).to be_a Hash
        expect(res_data.size).to eq 2
        expect(is_next).to eq false

      end
    end
  end

end
