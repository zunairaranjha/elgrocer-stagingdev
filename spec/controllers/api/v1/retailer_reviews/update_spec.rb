describe API::V1::RetailerReviews::Update, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer, {
      company_name: "Mr. Mohammet"
    })
  end

  let!(:retailer2) do
    FactoryBot.create(:retailer, {
      company_name: "Lake View"
    })
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, {
      name: 'Bob', phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')
    })
  end

  let!(:retailer_review) do
    FactoryBot.create(:retailer_review, {
      retailer_id: retailer.id,
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
      shopper_id: shopper.id,
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
      retailer_id: 65,
      shopper_id: shopper.id,
      comment: "A good shop.",
      overall_rating: 3,
      delivery_speed_rating: 3,
      order_accuracy_rating: 5,
      quality_rating: 4,
      price_rating: 3
    }
  end

  describe 'PUT /retailer_reviews' do
    subject(:request_response) {
      put '/api/v1/retailer_reviews', params: retailer_review_params, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_review) { JSON.parse(request_response.body) }
      it 'Contains data of an updated retailer review.' do
        res = returned_review
        expect(res['messages']).to eq nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_instance_of Hash
        expect(res['data']['comment']).to eq retailer_review_params[:comment]
        expect(res['data']['shopper_name']).to eq shopper.name
        expect(res['data']['average_rating']).to eq 4
      end
    end
  end

  describe 'PUT /retailer_reviews' do
    subject(:request_response) {
      put '/api/v1/retailer_reviews', params: retailer_review_params2, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it 'It will failed with status 422' do
      expect(subject.status).to eq 422
    end

    describe 'returned json' do
      subject(:returned_review) { JSON.parse(request_response.body) }
      it 'It should return an error with status code and message. Data should be abscent' do
        res = returned_review
        expect(res['messages']).not_to eq nil
        expect(res['status']).to eq "error"
        expect(res['messages']['error_message']['no_retailer_review']).not_to eq nil
        expect(res['data']).to eq nil
      end
    end
  end
end
