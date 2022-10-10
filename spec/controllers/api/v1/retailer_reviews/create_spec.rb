describe API::V1::RetailerReviews::Create, type: :request do
  let!(:retailer) do
    create(:retailer, {
      company_name: "Mr. Mohammet"
    })
  end

  let!(:retailer2) do
    create(:retailer, {
      company_name: "Lake View"
    })
  end

  let!(:shopper) do
    create(:shopper, {
      name: 'Bob',
      phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')
    })
  end

  let!(:retailer_review) do
    create(:retailer_review, {
      retailer_id: retailer2.id,
      shopper_id: shopper.id,
      comment: "I don't like this shop.",
      overall_rating: 2,
      delivery_speed_rating: 2,
      order_accuracy_rating: 2,
      quality_rating: 3,
      price_rating: 1
    })
  end

  let!(:retailer_review_params) do
    {
      retailer_id: retailer.id,
      comment: "A proffesional shop.",
      overall_rating: 4,
      delivery_speed_rating: 3,
      order_accuracy_rating: 5,
      quality_rating: 5,
      price_rating: 3
    }
  end

  let!(:retailer_review_params2) do
    {
      retailer_id: retailer2.id,
      comment: "A good shop.",
      overall_rating: 3,
      delivery_speed_rating: 3,
      order_accuracy_rating: 5,
      quality_rating: 4,
      price_rating: 3
    }
  end

  let!(:retailer_review_params3) do
    {
      retailer_id: 9999999889345768903,
      comment: "A proffesional shop.",
      overall_rating: 4,
      delivery_speed_rating: 3,
      order_accuracy_rating: 5,
      quality_rating: 5,
      price_rating: 3
    }
  end

  describe 'POST /retailer_reviews' do
    subject(:request_response) {
      post '/api/v1/retailer_reviews', params: retailer_review_params, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 201 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']

        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash

        expect(res_data['comment']).to eq retailer_review_params[:comment]
        expect(res_data['shopper_name']).to eq shopper.name
        expect(res_data['average_rating']).to eq 4
      end
    end
  end

  describe 'POST /retailer_reviews' do
    subject(:request_response) {
      post '/api/v1/retailer_reviews', params: retailer_review_params2, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 423 }
    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']

        expect(res['messages']).not_to be_nil
        expect(res['status']).not_to eq "success"
        expect(res['data']).not_to be_a Hash
      end
    end
  end

  describe 'POST /retailer_reviews' do
    subject(:request_response) {
      post '/api/v1/retailer_reviews', params: retailer_review_params3, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 410 }
    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']

        expect(res['messages']).not_to be_nil
        expect(res['status']).not_to eq "success"
        expect(res['data']).not_to be_a Hash
      end
    end
  end

  describe 'POST /retailer_reviews' do
    subject(:request_response) {
      post '/api/v1/retailer_reviews', params: retailer_review_params2, headers: { "Authentication-Token" => retailer2.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 403 }
    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']

        expect(res['messages']).not_to be_nil
        expect(res['status']).not_to eq "success"
        expect(res['data']).not_to be_a Hash
      end
    end
  end

end
