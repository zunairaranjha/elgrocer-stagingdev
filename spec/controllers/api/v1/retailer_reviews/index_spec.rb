describe API::V1::RetailerReviews::Index, type: :request do
  let!(:retailer) do
    FactoryBot.create(:retailer, {
      company_name: "Mr. Mohammet"
    })
  end

  let!(:shopper) do
    FactoryBot.create(:shopper, {
      name: 'Bob',
      phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0')
    })
  end

  let!(:retailer_review) do
    FactoryBot.create(:retailer_review, {
      shopper_id: shopper.id,
      retailer_id: retailer.id,
      comment: "A proffesional shop.",
      overall_rating: 4,
      delivery_speed_rating: 3,
      order_accuracy_rating: 5,
      quality_rating: 5,
      price_rating: 3
    })
  end

  describe 'GET /retailer_reviews' do
    subject(:request_response) {
      get '/api/v1/retailer_reviews', params: { limit: 20, offset: 0, retailer_id: retailer.id }, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
      response
    }
    it { expect(subject.status).to eq 200 }

    describe 'returned json' do
      subject(:returned_orders) { JSON.parse(request_response.body) }

      it 'contains data of product with all requested attributes' do
        res = returned_orders
        res_data = res['data']
        reviews_data = res_data['reviews']
        first_review = reviews_data[0]

        expect(res['messages']).to be_nil
        expect(res['status']).to eq "success"
        expect(res['data']).to be_a Hash

        expect(first_review['id']).to eq retailer_review.id
        expect(first_review['comment']).to eq retailer_review.comment
        expect(first_review['shopper_name']).to eq retailer_review.shopper_name
        expect(first_review['average_rating']).to eq retailer_review.average_rating
      end
    end
  end
end
