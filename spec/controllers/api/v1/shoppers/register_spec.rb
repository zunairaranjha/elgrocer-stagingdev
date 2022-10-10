describe API::V1::Shoppers::Register, type: :request do

  let!(:shopper) do
    FactoryBot.create(:shopper, {
      phone_number: Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0'),
      email: 'example2@dubai.com'
    })
  end

  describe 'POST /shoppers/register DESC: sign in retailer using correct credentials' do
    subject(:request_response) do
      post '/api/v1/shoppers/register', params: {
        password: 'password',
        password_confirmation: 'password',
        name: 'Bob Example',
        phone_number: '666999888',
        email: 'example@dubai.com'
      }, headers: { 'From-Spec' => true }
      response
    end

    its(:status) { is_expected.to eq 421 }

    # describe 'returned json' do
    #   subject(:returned_orders) { JSON.parse(request_response.body) }
    #   its(['status']) { is_expected.to eq 'success' }
    #   its(['messages']) { is_expected.to eq nil }
    #   its(['data']) { is_expected.to be_instance_of Hash }
    #
    # end
    # describe 'returned json' do
    #   subject(:returned_orders) { JSON.parse(request_response.body)['data'] }
    #   its(['name']) { is_expected.not_to eq 'Bob Example' }
    #
    # end
  end

  describe 'POST /shoppers/register DESC: sign in retailer using correct credentials but with existing user' do
    subject(:request_response) do
      post '/api/v1/shoppers/register', params: {
        password: 'password',
        password_confirmation: 'password',
        name: 'Bob Example',
        phone_number: '666999887',
        email: 'example2@dubai.com'
      }, headers: { 'From-Spec' => true }
      response
    end

    its(:status) { is_expected.to eq 421 }

  end

end