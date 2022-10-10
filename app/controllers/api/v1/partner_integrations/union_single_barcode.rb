class API::V1::PartnerIntegrations::UnionSingleBarcode < Grape::API
  version 'v1', using: :path
  format :json

  resources :partner_integrations do
    desc "Check Union Single Barcode"
    params do
      requires :branch_code, type: Integer, desc: "BranchCode of Union", documentation: { example: 18 }
      requires :barcode, type: String, desc: "Barcode", documentation: { example: '0318204055004' }
    end

    get '/union_single_barcode' do
      partner = PartnerIntegration.find_by(branch_code: params[:branch_code], integration_type: 1)
      if partner
        PartnerIntegration::UnionCoopFetchPriceStock.check_single_barcode(partner,params[:barcode])
      else
        error!({error_code: 422, error_message: "Partner Not Found"},422)
      end
    end
  end
end