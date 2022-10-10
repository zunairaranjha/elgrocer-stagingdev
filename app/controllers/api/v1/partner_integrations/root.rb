class API::V1::PartnerIntegrations::Root < Grape::API
  version 'v1', using: :path, vendor: 'api'
  format :json

  rescue_from :all, backtrace: true

  mount API::V1::PartnerIntegrations::UnionSingleBarcode
  mount API::V1::PartnerIntegrations::UnionCsvCheck
end
