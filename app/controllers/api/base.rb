require 'grape-swagger'
require 'doorkeeper/grape/helpers'

module API
  class Base < Grape::API
    helpers Doorkeeper::Grape::Helpers
    helpers do
      def doorkeeper_render_error_with(error)
        error!(CustomErrors.instance.unauthorized, 421)
      end

      def doorkeeper_authorize!(*scopes)
        scopes ||= Doorkeeper.configuration.default_scopes
        if valid_doorkeeper_token?(*scopes)
          if (doorkeeper_token.expires_at - (doorkeeper_token.expires_in && Time.now)) / 60 < 10.0 and ENV['TOKEN_EXPIRY_TIME'].to_i >= 60
            doorkeeper_token.expires_in = doorkeeper_token.expires_in + 3600
            doorkeeper_token.save
          end
        else
          doorkeeper_render_error
        end
      end
    end
    before do
      unless request.headers['App-Version'].present? || request.headers['User-Agent'].to_s =~ /ElGrocerShopper|Dalvik/ || request.headers['Authentication-Token'].to_s.eql?('36ninzmkhxHhWhxC8K8F') || request.fullpath.to_s =~ /webhooks|recent|payfort_|adyen_/ || request.headers['From-Spec'].present?
        params[:access_token] = request.headers['Access-Token']
        doorkeeper_authorize!
      end
      params.except!(:access_token) #for cache control
      I18n.locale = request.headers['Locale'] || params[:locale] || I18n.default_locale
      # params[:ip_address] = request.ip
    end

    mount API::V4::Base
    mount API::V3::Base
    mount API::V2::Base
    mount API::V1::Base
    add_swagger_documentation base_path: '/api',
                              api_version: 'v1',
                              hide_documentation_path: true
  end
end