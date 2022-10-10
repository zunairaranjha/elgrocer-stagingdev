describe API::V1::PromotionCodes::CheckAndRealize, type: :request do
  let!(:retailer) { FactoryBot.create(:retailer) }
  let!(:shopper) { FactoryBot.create(:shopper, { phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') }) }
  let!(:brand) { FactoryBot.create(:brand) }

  let!(:product1) { FactoryBot.create(:product, brand: brand) }
  let!(:product2) { FactoryBot.create(:product, brand: brand) }

  let!(:shop1) do
    FactoryBot.create(:shop, product_id: product1.id,
                      retailer_id: retailer.id, commission_value: 11, price_dollars: 0, price_cents: 1)
  end

  let!(:shop2) do
    FactoryBot.create(:shop, product_id: product2.id, retailer_id: retailer.id, price_dollars: 0, price_cents: 10)
  end

  let!(:promotion_code) { FactoryBot.create(:promotion_code, allowed_realizations: 1, retailers: [retailer], brands: [brand]) }

  let!(:check_code_params) do
    {
      retailer_id: retailer.id,
      promo_code: promotion_code.code,
      products: [
        {
          product_id: product1.id,
          amount: 1
        },
        {
          product_id: product2.id,
          amount: 3
        }
      ]
    }
  end

  let!(:check_code_params2) do
    {
      retailer_id: retailer.id,
      promo_code: promotion_code.code,
      products: [
        {
          product_id: product1.id,
          amount: 1
        }
      ]
    }
  end

  describe 'POST /promotion_codes/check_and_realize' do
    context 'when params are correct' do
      subject(:request_response) {
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 201 }

      describe 'returned json' do
        subject(:returned_code) { JSON.parse(request_response.body) }

        it 'contains data of promotion code realization id' do
          res = returned_code
          expect(res['messages']).to be_nil
          expect(res['status']).to eq 'success'
          expect(res['data']).to be_a Hash
        end
      end
    end

    context 'when request many times same code' do
      subject(:request_response) do
        5.times do
          post '/api/v1/promotion_codes/check_and_realize', params: check_code_params, headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
        end
        response
      end

      describe 'returned json' do
        it 'contains data of promotion code realization id' do
          res = JSON.parse(subject.body)
          expect(res['messages']).to be_nil
          expect(res['status']).to eq 'success'
          expect(res['data']).to be_a Hash
        end
      end
    end

    #context 'when request without minimal value of brand code' do
    #  subject(:request_response) {
    #    post '/api/v1/promotion_codes/check_and_realize', params: check_code_params2, headers: {"Authentication-Token" => shopper.authentication_token}
    #    response
    #  }
    #
    #  it { expect(subject.status).to eq 422 }
    #
    #  describe 'returned json' do
    #    it 'contains error' do
    #      res = JSON.parse(subject.body)
    #      expect(res['messages']['error_code']).to eq 10_007
    #    end
    #  end
    #end

    context 'when sending not existing promocode' do
      subject(:request_response) {
        post '/api/v1/promotion_codes/check_and_realize', params: check_code_params2.merge(promo_code: 'not_exist'), headers: { "Authentication-Token" => shopper.authentication_token, "From-Spec" => true }
        response
      }

      it { expect(subject.status).to eq 422 }

      describe 'returned json' do
        it 'contains error' do
          res = JSON.parse(subject.body)
          expect(res['messages']['error_code']).to eq 10_005
        end
      end
    end
  end
end
