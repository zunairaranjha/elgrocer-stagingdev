class AddApnCertificateToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :apn_certificate, :binary
  end
end
