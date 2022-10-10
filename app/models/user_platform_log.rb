class UserPlatformLog < ApplicationRecord
  belongs_to :shopper

  enum platform_type: {
    elgrocer: 0,
    smiles: 1,
  }

  enum device_type: {
    android: 0,
    ios: 1
  }

  def self.add_logs(shopper)
    begin
      upl = UserPlatformLog.new
      upl.shopper_id = shopper.id
      upl.device_type = shopper.device_type
      upl.platform_type = shopper.platform_type
      upl.app_version = shopper.app_version
      upl.save rescue e
    end
  end

end
