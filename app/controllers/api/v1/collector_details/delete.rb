module API
  module V1
    module CollectorDetails
      class Delete < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :collector_details do
          desc "Delete Collector details"
      
          params do
            requires :id, type: Integer, desc: "id of collector"
          end
      
          put '/delete' do
            error!(CustomErrors.instance.unauthorized, 421) unless current_shopper
            CollectorDetail.where(id: params[:id],shopper_id: current_shopper.id).update_all(is_deleted: true, updated_at: Time.now)
            present message: true
          end
        end
      end      
    end
  end
end