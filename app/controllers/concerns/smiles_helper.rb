# frozen_string_literal: true

module Concerns
  module SmilesHelper
    extend Grape::API::Helpers

    def debit_smiles_points(order)
      smiles_auth_token
      payment_via_smiles_points(order)
    end

    def update_debit_smiles_points(order, order_total_value, is_active: false)
      smiles_auth_token
      update_payment_via_smiles_points(order, order_total_value, is_active)
    end

    def smiles_auth_token
      Loyalty::Smiles.new.smiles_auth unless Redis.current.get('smiles_access_token').present?
    end

    def get_shopper_smiles_info(shopper,order, is_active = false)
      response = Loyalty::Smiles.new.get_smiles_member_info(shopper.smiles_phone_format)
      res = JSON(response.body)
      if res['getMemberResponse']['ackMessage']['status'] == 'SUCCESS'
        Redis.current.del("smiles_member_info_#{shopper.id}")
        ut = shopper.unique_smiles_token.to_s.split('$')
        if ut[0] == res['getMemberResponse']['accountsInfo'][0]['loyaltyId'] && ut[1] == shopper.registration_id && res['getMemberResponse']['accountsInfo'][0]['accountStatus'] == 'Active' || order.platform_type.eql?('smiles') || is_active || request.headers['Loyalty-Id'].present?
          # check_loyalty_subscription(order, res)
          res
        else
          error!(CustomErrors.instance.loyalty_sign_in, 421)
        end
      # elsif order.platform_type.eql?('smiles')
      #   response = Loyalty::Smiles.new.sdk_smiles_login(shopper.smiles_loyalty_id)
      #   if SUCCESSFUL_HTTP_STATUS.include?(response.status)
      #     response = Loyalty::Smiles.new.get_smiles_member_info(shopper.smiles_phone_format)
      #     error!(CustomErrors.instance.server_error, 421) if response.status == 500
      #     res = JSON(response.body)
      #     if SUCCESSFUL_HTTP_STATUS.include?(response.status)
      #       res
      #     else
      #       error!(CustomErrors.instance.send(res['getMemberResponse']['ackMessage']['errorCode'].underscore), 421)
      #     end
      #   else
      #     error!(CustomErrors.instance.send(res['loginResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['loginResponse']['ackMessage']['errorDescription'], 421)
      #   end
      else
        error!(CustomErrors.instance.send(res['getMemberResponse']['ackMessage']['errorCode'].underscore), 421)
        # error!(res["getMemberResponse"]["ackMessage"]["errorDescription"] || res["getMemberResponse"]["ackMessage"]["errorType"], 421)
      end
    end

    def redeem_smiles_points(spend_value, order, phone_number, burning, order_amount)
      req = {
        account_number: phone_number,
        activity_code: 'ELGRRED',
        redemption_type: 'direct',
        points_value: spend_value
      }
      # response = Loyalty::Smiles.new.smiles_member_activity(req)
      res = JSON(Loyalty::Smiles.new.smiles_member_activity(req).body)
      if res['memberActivityResponse']['AckMessage']['Status'] == 'SUCCESS'
        od = OrdersDatum.find_by_order_id(order.id)
        transactions = od.detail['transaction_ref_ids'].present? ? od.detail['transaction_ref_ids'].merge({ "#{res['memberActivityResponse']['transactionRefId']}": spend_value }) : { "#{res['memberActivityResponse']['transactionRefId']}": spend_value }
        od.detail['transaction_ref_ids'] = transactions
        od.save rescue ''
        send_kafka_event('Smiles Burn', req, res, order, burning, order_amount)
        res
      else
        send_kafka_event('Smiles Burn Failed', req, res, order, burning, order_amount)
        error!(CustomErrors.instance.send(res['memberActivityResponse']['AckMessage']['ErrorCode'].underscore), 421) rescue error!(res['memberActivityResponse']['AckMessage']['ErrorDescription'], 421)
      end
    end

    def smile_points_rollback(transaction_ref_ids, od, order)
      # od = OrdersDatum.find_by_order_id(order.id)
      rollback_transactions = od.detail['rollbacked_transaction_ids'].present? ? od.detail['rollbacked_transaction_ids'] : {}
      transaction_ref_ids.each do |transaction_ref_id|
        sp = od.detail['transaction_ref_ids'][transaction_ref_id]
        res = shoot_rollback_call(transaction_ref_id)
        res.merge!(smiles_points: sp)
        if res['rollbackResponse']['ackMessage']['status'] == 'SUCCESS'
          rollback_transactions[transaction_ref_id.to_s] = od.detail['transaction_ref_ids'].delete(transaction_ref_id.to_s)
          od.detail['rollbacked_transaction_ids'] = rollback_transactions
          od.save
          Redis.current.del("smiles_member_info_#{order.shopper_id}")
          send_kafka_event('Smiles Burn Rollback Transactions', transaction_ref_id, res, order)
          res
        else
          # error!(CustomErrors.instance.send(res['rollbackResponse']['ackMessage']['errorCode'].underscore), 421)
          send_kafka_event('Smiles Burn Rollback Transactions Failed', transaction_ref_id, res, order)
          error!(CustomErrors.instance.send(res['rollbackResponse']['ackMessage']['errorCode'].underscore), 421) rescue error!(res['rollbackResponse']['ackMessage']['errorDescription'] || res['memberActivityResponse']['ackMessage']['errorType'], 421)
        end
      end
    end

    def payment_via_smiles_points(order)
      shopper = current_shopper.present? ? current_shopper : order.shopper
      smiles_total_points = get_shopper_smiles_info(shopper, order)['getMemberResponse']['accountsInfo'][0]['totalPoints'].to_i
      # burning = Partner.find_by_name('smile_data').config["burning"]
      burning = JSON(Partner.get_key_value('smile_data'))['burning'].to_f
      sp_total_value = (order.total_price / burning.to_f).round
      error!(CustomErrors.instance.low_smiles_balance, 421) if smiles_total_points.to_i < sp_total_value
      redeem_smiles_points(sp_total_value, order, shopper.smiles_phone_format, burning, order.total_price)
    end

    def update_payment_via_smiles_points(order, order_total_value, is_active)
      # burning = Partner.find_by_name('smile_data').config["burning"]
      burning = JSON(Partner.get_key_value('smile_data'))['burning'].to_f
      shopper = current_shopper.present? ? current_shopper : order.shopper
      smiles_order_total_value = (order_total_value / burning.to_f).round
      smiles_order_total_value_was = order.orders_datum.detail['transaction_ref_ids'].to_h.values.sum
      smiles_total_points = get_shopper_smiles_info(shopper, order, is_active)['getMemberResponse']['accountsInfo'][0]['totalPoints'].to_i
      if smiles_order_total_value > smiles_order_total_value_was
        sp_total_value = smiles_order_total_value - smiles_order_total_value_was
        error!(CustomErrors.instance.low_smiles_balance, 421) if smiles_total_points.to_i < sp_total_value
        redeem_smiles_points(sp_total_value, order, shopper.smiles_phone_format, burning, order_total_value)
      elsif smiles_order_total_value < smiles_order_total_value_was
        # smile_points_rollback(order)
        redeem = smiles_transactions_to_rollback(order, (smiles_order_total_value_was - smiles_order_total_value))
        # error!(CustomErrors.instance.low_smiles_balance, 421) if smiles_total_points.to_i < smiles_order_total_value
        redeem_smiles_points(smiles_order_total_value, order, shopper.smiles_phone_format, burning, order_total_value) if smiles_order_total_value.positive? && redeem
      end
    end

    def accrual_smiles_points(order, amount)
      smiles_auth_token
      # earning = Partner.find_by_name('smile_data').config["earning"]
      earning = JSON(Partner.get_key_value('smile_data'))['earning'].to_f
      shopper_pn = order.shopper.smiles_phone_format
      member_res = JSON(Loyalty::Smiles.new.get_smiles_member_info(shopper_pn).body)
      unless member_res['getMemberResponse']['ackMessage']['status'] == 'SUCCESS' || member_res['getMemberResponse']['accountsInfo'][0]['accountStatus'] == 'Active'
        send_kafka_event('Smiles Earn Failed', { account_number: shopper_pn }, member_res, order, earning, amount)
        return
      end
      req = {
        account_number: shopper_pn,
        activity_code: 'ELGRACR',
        spend_value: (amount * earning).floor
      }
      response = Loyalty::Smiles.new.smiles_member_activity(req)
      res = JSON(response.body)
      if res['memberActivityResponse']['AckMessage']['Status'] == 'SUCCESS'
        Redis.current.del("smiles_member_info_#{order.shopper_id}")
        OrdersDatum.post_data(order.id, detail: { 'smile_accrual_points' => { "#{res['memberActivityResponse']['transactionRefId']}": req[:spend_value] } })
        send_kafka_event('Smiles Earn', req, res, order, earning, amount)
        res
      else
        send_kafka_event('Smiles Earn Failed', req, res, order, earning, amount)
      end
    end

    def smiles_transactions_to_rollback(order, rollback_amount = nil)
      od = OrdersDatum.find_by_order_id(order.id)
      rollback_transactions = od.detail['transaction_ref_ids']
      return true if rollback_transactions.blank?

      redeem = false
      transaction_to_rollback = [rollback_transactions.key(rollback_amount)]
      if transaction_to_rollback[0].blank?
        transaction_to_rollback = od.detail['transaction_ref_ids'].keys
        redeem = true
      end
      # transaction_to_rollback
      smile_points_rollback(transaction_to_rollback, od, order)
      redeem
    end

    def earn_smile_points_rollback(order)
      od = OrdersDatum.find_by_order_id(order.id)
      return if od.blank? || od.detail['smile_accrual_points'].blank?

      rollback_transactions = od.detail['rollback_earn_transaction_ids'].present? ? od.detail['rollback_earn_transaction_ids'] : {}
      od.detail['smile_accrual_points'].keys.each do |transaction_ref_id|
        sp = od.detail['smile_accrual_points'][transaction_ref_id]
        res = shoot_rollback_call(transaction_ref_id)
        res.merge!(smiles_points: sp)
        if res['rollbackResponse']['ackMessage']['status'] == 'SUCCESS'
          rollback_transactions[transaction_ref_id.to_s] = od.detail['smile_accrual_points'].delete(transaction_ref_id.to_s)
          od.detail['rollback_earn_transaction_ids'] = rollback_transactions
          od.save
          Redis.current.del("smiles_member_info_#{order.shopper_id}")
          send_kafka_event('Smiles Earn Rollback Transactions', transaction_ref_id, res, order)
          res
        else
          # error!(CustomErrors.instance.send(res['rollbackResponse']['ackMessage']['errorCode'].underscore), 421)
          send_kafka_event('Smiles Earn Rollback Transactions Failed', transaction_ref_id, res, order)
          error!(CustomErrors.instance.send(res['rollbackResponse']['ackMessage']['errorCode'].underscore), 421) rescue error!(res['rollbackResponse']['ackMessage']['errorDescription'] || res['memberActivityResponse']['ackMessage']['errorType'], 421)
        end
      end
    end

    # def check_loyalty_subscription(order, res)
      # sub_status = res['getMemberResponse']['accountsInfo'][0]['foodSubscriptionStatus']
      # od = OrdersDatum.find_by_order_id(order.id)
      # od.detail['smiles_tier_level'] = res['getMemberResponse']['accountsInfo'][0]['tierLevel']
      # od.detail['smiles_food_subscription_status'] = false
      # od.save
      # order.service_fee = 0 if sub_status
      # order.save
    # end

    def shoot_rollback_call(transaction_ref_id)
      response = Loyalty::Smiles.new.smiles_rollback(transaction_ref_id)
      JSON(response.body)
    end

    def smiles_logs(event, req, res, order, formula = nil, order_amount = nil)
      SmilesTransactionLog.add_activity(event, req, res, order, formula, order_amount)
    end

    def send_kafka_event(event, params, response, order, formula = nil, order_amount = nil)
      smiles_logs(event, params, response, order, formula, order_amount)
      response.merge!(order_amount: order_amount)
      RequestResponseStreamJob.perform_later(topic: SystemConfiguration.get_key_value('smiles_topic'), owner: order, event: "#{event}, Formula: #{formula}", request: params, response: response)
    end
  end
end
