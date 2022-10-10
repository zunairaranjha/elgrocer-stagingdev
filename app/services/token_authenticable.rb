module TokenAuthenticable

  def self.included(base)

    base.before do
      error!("Unauthorized", 401) unless authenticated
    end

    base.helpers do
      def warden
        env['warden']
      end

      def authenticated
        return true if warden.authenticated?
        if (@employee = Employee.find_by_authentication_token(request.headers["Authentication-Token"]))
          request.headers["Authentication-Token"] && @employee
        elsif (@shopper = Shopper.find_by_authentication_token(request.headers["Authentication-Token"]))
          request.headers["Authentication-Token"] && @shopper
        elsif (@retailer = Retailer.find_by_authentication_token(request.headers["Authentication-Token"]))
          request.headers["Authentication-Token"] && @retailer
        end
      end

      def current_retailer
        warden.user || @retailer || @employee.try(:retailer)
      end

      def current_shopper
        warden.user || @shopper
      end

      def current_employee
        warden.user || @employee
      end
    end
  end
end
