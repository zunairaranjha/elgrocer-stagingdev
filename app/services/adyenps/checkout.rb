# Methods from the Adyen API Library for Ruby are defined here in the model and
# called from `CheckoutsController`.

# Note that certain values have been hard-coded for simplicity (i.e., you'll
# want to obtain some data from external resources or generate them at runtime).

require 'adyen-ruby-api-library'

module Adyenps
  class Checkout
    include Adyen

    class << self

      def get_payment_methods(params)
        payment_params = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          shopperLocale: 'en-US'
        }

        payment_params[:channel] = params['channel'] if params['channel'].present?
        payment_params[:shopperReference] = adjust_shopper_reference(params['shopperReference']) if params['shopperReference'].present?
        payment_params[:amount] = params['amount'] if params['amount'].present?
        payment_params[:countryCode] = params['countryCode'] if params['countryCode'].present?
        payment_params[:shopperLocale] = params['shopperLocale'] if params['shopperLocale'].present?

        adyen_client.checkout.payment_methods(payment_params)
      end

      # Makes the /payments request
      # https://docs.adyen.com/api-explorer/#/PaymentSetupAndVerificationService/payments
      def make_payment(params)
        # currency = 'AED' # find_currency(payment_method["type"])
        # order_ref = SecureRandom.uuid

        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          channel: params['channel'], # required
          amount: params['amount'],
          storePaymentMethod: params['storePaymentMethod'],
          reference: params['reference'], # required
          additionalData: {
            # required for 3ds2 native flow
            allow3DS2: true,
            "authorisationType": 'PreAuth'
          },
          shopperIP: params['remote_ip'], # required by some issuers for 3ds2
          returnUrl: params['return_url'], # "http://127.0.0.1:3000/api/handleShopperRedirect?orderRef=#{order_ref}", # required for 3ds2 redirect flow
          paymentMethod: params['paymentMethod'], # required
          # "recurringProcessingModel": "CardOnFile",
          "shopperReference": adjust_shopper_reference(params['shopperReference'])
        }
        req[:origin] = params['origin'] if params['origin'].present?
        req[:shopperEmail] = params['shopperEmail'] if params['shopperEmail'].present?
        req[:billingAddress] = params['billingAddress'] if params['billingAddress'].present?
        req[:browserInfo] = params['browserInfo'] if params['browserInfo'].present?
        req[:shopperInteraction] = params['shopperInteraction'] if params['shopperInteraction'].present?

        adyen_client.checkout.payments(req)
      end

      # Makes the /payments/details request
      # https://docs.adyen.com/api-explorer/#/PaymentSetupAndVerificationService/payments/details
      def submit_details(details)
        adyen_client.checkout.payments.details(details)
      end

      # Makes the /amountUpdates request
      # https://docs.adyen.com/api-explorer/#/PaymentSetupAndVerificationService/amountUpdates
      def amount_updates(params)
        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          # :amount => params['amount'],
          # :paymentPspReference => params['paymentPspReference'],
          reference: params['reference'],
          reason: params['reason'],
          originalReference: params['originalReference'],
          modificationAmount: params['modificationAmount'],
          additionalData: params['additionalData']
        }
        update_amount(req)
      end

      # Makes the /adjust_authorisation sync request
      def adjust_authorisation(params)
        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          reference: params['reference'],
          originalReference: params['originalReference'],
          modificationAmount: params['modificationAmount'],
          additionalData: {
            adjustAuthorisationData: params['adjustAuthorisationData']
          }
        }
        adyen_client.payments.adjust_authorisation(req)
      end

      # Makes the /capture request
      def capture(params)
        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          reference: params['reference'],
          reason: params['reason'],
          originalReference: params['originalReference'],
          modificationAmount: params['modificationAmount'],
          additionalData: params['additionalData']
        }
        adyen_client.payments.capture(req)
      end

      # Makes the /cancel request
      def cancel(params)
        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          reference: params['reference'],
          reason: params['reason'],
          originalReference: params['originalReference'],
          additionalData: params['additionalData']
        }
        adyen_client.payments.cancel(req)
      end

      # Makes the /refund request
      def refund(params)
        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          reference: params['reference'],
          reason: params['reason'],
          originalReference: params['originalReference'],
          modificationAmount: params['modificationAmount'],
          additionalData: params['additionalData']
        }
        adyen_client.payments.refund(req)
      end

      # Makes the /cancel_or_refund request
      def cancel_or_refund(params)
        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          reference: params['reference'],
          reason: params['reason'],
          originalReference: params['originalReference'],
          modificationAmount: params['modificationAmount'],
          additionalData: params['additionalData']
        }
        adyen_client.payments.cancel_or_refund(req)
      end

      # Makes the /disable payment payment detail request
      def disable_payment(params)
        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          shopperReference: adjust_shopper_reference(params['shopperReference'])
        }
        req[:recurringDetailReference] = params['recurringDetailReference'] if params['recurringDetailReference'].present?

        adyen_client.recurring.disable(req)
      end

      # Makes the /payment_session request
      def payment_session(params)
        req = {
          merchantAccount: ENV['ADYEN_MERCHANT_ACCOUNT'],
          amount: params['amount'],
          returnUrl: params['returnUrl'],
          reference: params['reference']
        }
        req[:expiresAt] = params['expiresAt'] if params['expiresAt'].present?
        req[:countryCode] = params['countryCode'] if params['countryCode'].present?
        req[:shopperLocale] = params['shopperLocale'] if params['shopperLocale'].present?
        req[:shopperEmail] = params['shopperEmail'] if params['shopperEmail'].present?
        req[:sdkVersion] = params['sdkVersion'] if params['sdkVersion'].present?
        req[:token] = params['token'] if params['token'].present?

        adyen_client.checkout.payment_session(req)
      end

      def void_authorization(params)
        # req = {
        #   :merchantAccount => ENV["ADYEN_MERCHANT_ACCOUNT"],
        #   :originalReference => params['originalReference'],
        # }
        # req[:reference] = params['reference'] if params["reference"].present?

        # response = adyen_client.payments.cancel(req)
        # response
        cancel(params)
      end

      private

      def adyen_client
        @adyen_client ||= instantiate_checkout_client
      end

      def instantiate_checkout_client
        adyen = Adyen::Client.new
        adyen.api_key = ENV['ADYEN_APIKEY']
        adyen.env = ENV['ADYEN_ENV'].to_sym
        adyen.live_url_prefix = ENV['ADYEN_LIVE_URL_PREFIX'] if ENV['ADYEN_ENV'].to_s.eql?('live')
        adyen.checkout.version = 68
        adyen
      end

      def update_amount(params)
        # def adyen_client.service_url_base(service)
        #   raise ArgumentError, "Please set Client.live_url_prefix to the portion of your merchant-specific URL prior to '-[service]-live.adyenpayments.com'" if @live_url_prefix.nil? and @env == :live
        #   if @env == :mock
        #     @mock_service_url_base
        #   else
        #     case service
        #     when 'Checkout'
        #       url = "https://checkout-#{@env}.adyen.com"
        #       supports_live_url_prefix = true
        #     when 'Account', 'Fund', 'Notification', 'Hop'
        #       url = "https://cal-#{@env}.adyen.com/cal/services"
        #       supports_live_url_prefix = false
        #     when 'Recurring', 'Payment', 'Payout', 'BinLookup'
        #       url = "https://pal-#{@env}.adyen.com/pal/servlet"
        #       supports_live_url_prefix = true
        #     when 'Terminal'
        #       url = "https://postfmapi-#{@env}.adyen.com/postfmapi/terminal"
        #       supports_live_url_prefix = false
        #     when 'DataProtectionService', 'DisputeService'
        #       url = "https://ca-#{@env}.adyen.com/ca/services"
        #       supports_live_url_prefix = false
        #     else
        #       raise ArgumentError, 'Invalid service specified'
        #     end
        #
        #     if @env == :live && supports_live_url_prefix
        #       url.insert(8, "#{@live_url_prefix}-")
        #       url['adyen.com'] = 'adyenpayments.com'
        #     end
        #
        #     return url
        #   end
        # end

        params[:amount] = params.delete(:modificationAmount)
        adyen_client.call_adyen_api('Checkout', "payments/#{params[:originalReference]}/amountUpdates", params.except(:originalReference, :additionalData), {}, adyen_client.checkout.version)
      end

      def find_currency(type)
        case type
        when 'ach'
          'USD'
        when 'wechatpayqr', 'alipay'
          'CNY'
        when 'dotpay'
          'PLN'
        when 'boletobancario'
          'BRL'
        else
          'EUR'
        end
      end

      def adjust_shopper_reference(value)
        value.to_s.rjust(3, '0')
      end
    end
  end
end
