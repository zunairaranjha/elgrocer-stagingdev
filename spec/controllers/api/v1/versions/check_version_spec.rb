describe API::V1::Versions::CheckVersion, type: :request do
  before :each do
    FactoryBot.create(:version, majorversion: 1, minorversion: 0, revision: 0, action: 0)
    FactoryBot.create(:version, majorversion: 1, minorversion: 0, revision: 1, action: 0)
    FactoryBot.create(:version, majorversion: 1, minorversion: 2, revision: 1, action: 1)
    FactoryBot.create(:version, majorversion: 2, minorversion: 2, revision: 0, action: 1)
    FactoryBot.create(:version, majorversion: 2, minorversion: 2, revision: 10, action: 0)
  end

  describe 'POST /versions/check_version If I have old application' do
    subject(:request_response) do
      post '/api/v1/versions/check_version', params: { client_version: '1.0.0', client_type: '1' }, headers: { "From-Spec" => true }
      response
    end

    describe 'returned json' do
      it 'contains data of action to update' do
        res = JSON.parse(subject.body)

        expect(res['messages']).to be_nil
        expect(res['status']).to eq 'success'
        expect(res['data']['action']).to eq 1
      end
    end
  end

  describe 'POST /versions/check_version If I have last required version of application' do
    subject(:request_response) do
      post '/api/v1/versions/check_version', params: { client_version: '2.2.0', client_type: '1' }, headers: { "From-Spec" => true }
      response
    end

    describe 'returned json' do
      it 'contains data of action to do nothing' do
        res = JSON.parse(subject.body)
        expect(res['messages']).to be_nil
        expect(res['status']).to eq 'success'
        expect(res['data']['action']).to eq 0
      end
    end
  end

  describe 'POST /versions/check_version If I have version not in db' do
    subject(:request_response) do
      post '/api/v1/versions/check_version', params: { client_version: '99.2.0', client_type: '1' }, headers: { "From-Spec" => true }
      response
    end

    describe 'returned json' do
      it 'contains data of action to do nothing' do
        res = JSON.parse(subject.body)

        expect(res['messages']).to be_nil
        expect(res['status']).to eq 'success'
        expect(res['data']['action']).to eq 0
      end
    end
  end
end
