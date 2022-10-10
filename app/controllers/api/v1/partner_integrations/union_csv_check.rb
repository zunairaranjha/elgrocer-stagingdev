class API::V1::PartnerIntegrations::UnionCsvCheck < Grape::API
  version 'v1', using: :path
  format :json

  resources :partner_integrations do
    desc "Check Union Csv"
    params do
      requires :link, type: String, desc: "CSV File Link", documentation: { example: "example.com" }
      requires :emails, type: String, desc: "Comma separated emails", documentation: { example: 'example@example.com,example2@example.com' }
    end

    get '/union_csv_check' do
      # DigestUnionBarcodesJob.perform(params[:link], params[:emails])
      Resque.enqueue(DigestUnionBarcodesJob, params[:link], params[:emails])
      true
    end
  end
end