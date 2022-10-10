class CreatePartnerOauthTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :partner_oauth_tokens do |t|
      t.string :partner_name
      t.jsonb :detail, default: {}

      t.timestamps
    end
  end
end
