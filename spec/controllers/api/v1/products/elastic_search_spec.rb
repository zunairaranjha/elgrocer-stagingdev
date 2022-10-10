#require 'rails_helper'
#
#describe API::V1::Products::ElasticSearch, type: :request do
#  describe "POST /elastic_search" do
#
#    let!(:shopper) { create(:shopper) }
#    let!(:retailer) { create(:retailer) }
#    before do
#      product = create(:product, name: 'test')
#      mac = create(:product, name: 'macbook')
#
#      create(:shop, retailer: retailer, product: product)
#      create(:shop, retailer: retailer, product: mac)
#
#      Product.__elasticsearch__.create_index! force: true
#      Product.import
#      Shop.__elasticsearch__.create_index! force: true
#      Shop.import
#      sleep 1
#    end
#
#    context 'as Retailer' do
#      subject(:request_response) do
#        post '/api/v1/products/elastic_search', {search_input: 'test', page: 1}, {"Authentication-Token" => retailer.authentication_token}
#        response
#      end
#
#      it { expect(subject).to eq 201 }
#
#      subject do
#        post '/api/v1/products/elastic_search', {search_input: 'test', location: 1, page: 1}, {"Authentication-Token" => retailer.authentication_token}
#      end
#
#      it { is_expected.to eq 201 }
#
#      describe 'returned json' do
#        subject(:returned_orders) {JSON.parse(request_response.body)}
#
#        it 'contains data of product with all requested attributes' do
#          res = returned_orders
#          expect(res['data'].count).to eq 1
#          expect(res['messages']).to be_nil
#          expect(res['status']).to eq "success"
#        end
#
#        subject do
#          post '/api/v1/products/elastic_search', {search_input: 'osx', page: 1}, {"Authentication-Token" => retailer.authentication_token}
#          response
#        end
#
#        it 'contains data of product with synonym name request' do
#          res = JSON.parse(subject.body)
#          expect(res['data']['products'].count).to eq 1
#          expect(res['messages']).to be_nil
#          expect(subject.status).to eq 201
#        end
#      end
#    end
#  end
#end
