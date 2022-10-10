
class ResetSmilesOtpAttemptsJob
  @queue = :reset_smiles_attempts_queue

  def self.perform
    ShoppersDatum.where("(detail->>'smiles_retry_otp_attempts' > '0' or detail->>'smiles_invalid_otp_attempts' > '0' )").update_all(
      "detail = detail::jsonb || '{\"smiles_invalid_otp_attempts\": 0,\"smiles_retry_otp_attempts\": 0,\"smiles_retry_otp_attempts_blocked\": false,\"smiles_invalid_otp_attempts_blocked\": false}'::jsonb"
    )
  end
end