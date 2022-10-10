class PartnerOauthToken < ApplicationRecord
  def self.create_log(name, detail)
    PartnerOauthToken.create(partner_name: name, detail: detail)
  end
end