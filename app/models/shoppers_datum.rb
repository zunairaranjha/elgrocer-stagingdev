class ShoppersDatum < ApplicationRecord
  ############# Associations ##############
  has_one :shopper

  #================= Increment Smiles retry OTP and invalid OTP Attempts And Block Smiles User's OTP ========================#

  def self.increment_smiles_otp_attempts(shopper_id, smiles_attempt)
    sd = ShoppersDatum.find_or_initialize_by(shopper_id: shopper_id)
    if sd.detail[smiles_attempt].to_i > JSON(Partner.get_key_value('smile_data'))["#{smiles_attempt}_limit"].to_i
      sd.detail["#{smiles_attempt}_blocked"] = true
    else
      sd.detail[smiles_attempt] = sd.detail[smiles_attempt].to_i + 1
      sd.detail["#{smiles_attempt}_blocked"] = false
    end
    sd.save
  end

  #================ Resent Smiles OTP Attempts when user logged in =====================#

  def reset_smiles_otp_attempts
    detail['smiles_retry_otp_attempts'] = 0
    detail['smiles_invalid_otp_attempts'] = 0
    save
  end

  def unblock_otp_block_attempts
    detail['smiles_retry_otp_attempts_blocked'] = false
    detail['smiles_invalid_otp_attempts_blocked'] = false
    save
  end

end
