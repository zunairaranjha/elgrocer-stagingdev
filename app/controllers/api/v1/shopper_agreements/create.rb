module API
  module V1
    module ShopperAgreements
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :shopper_agreements do
      
          desc "Allows Creation of Shopper Agreements."
      
          params do
            requires :accepted, type: Boolean, desc: "Legal Age or not"
            requires :agreement, type: String, desc: "Agrement Text"
          end
      
          post do
            if current_shopper
              user_agreement = ShopperAgreement.new(
                  shopper_id: current_shopper.id,
                  accepted: params[:accepted],
                  agreement: params[:agreement]
              )
              true if user_agreement.save!
            else
              error!(CustomErrors.instance.not_allowed, 421)
            end
          end
        end
      end      
    end
  end
end