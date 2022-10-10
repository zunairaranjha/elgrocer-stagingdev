# frozen_string_literal: true

module API
  module V2
    module Shoppers
      class Wallet < Grape::API
        version 'v2', using: :path
        format :json
      
        resource :shoppers do
          desc "List of shopper's wallet." #, entity: API::V2::Shoppers::Entities::WalletEntity
          params do
            optional :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :shopper_id, type: Integer, desc: 'Shopper id', documentation: { example: 20 }
          end
          get '/wallet' do
            # wallets = ReferralWallet.where(shopper_id: params[:shopper_id], order_id: nil).where('expire_date > ?', DateTime.now)
            shopper = Shopper.find(params[:shopper_id])
            
            wallets = shopper.referral_wallets.available 
            wallets = wallets.limit(params[:limit]).offset(params[:offset])
            # .select(:id, :amount, :expire_date, :referral_rule_id, :info)
      
            # is_next = false
            # is_next = wallets.count(:id).count > params[:limit].to_i + params[:offset].to_i
            is_next = wallets.except(:offset, :limit, :order).count(:id).count > params[:limit].to_i + params[:offset].to_i
      
            referral_link = "http://elgrocer.com/register?rc=#{shopper.referral_code}"
            signup_rule = ReferralRule.where(is_active: true, event_id: 1).first
            if signup_rule
              message = signup_rule.message || "no active referral with event_id: 1"   
              message = message.gsub('[NAME]', shopper.name || shopper.referral_code)
              message = message.gsub('[URL]', referral_link)
            end
      
            referrer_amount = ReferralRule.where(is_active: true).where('referrer_amount > 0').pluck(:referrer_amount).first
            referee_amount = ReferralRule.where(is_active: true).where('referee_amount > 0').pluck(:referee_amount).first
      
      
            is_referral_system_active = ReferralRule.where(is_active: true).count > 0
      
            result = {is_next: is_next, is_referral_system_active: is_referral_system_active, referral_code: shopper.referral_code, referral_url: referral_link, referrer_amount: referrer_amount,referee_amount: referee_amount, invite_message: message, wallet_total: shopper.wallet_total, referral_wallets: wallets}
            #present result, with: API::V2::Shoppers::Entities::WalletEntity, shopper_id: params[:shopper_id]
          end
        end
      end
    end
  end
end