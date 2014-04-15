class CreateSocialAccounts < ActiveRecord::Migration
  def change
    create_table :social_accounts do |t|
      t.integer :user_id
      t.string :provider_name
      t.string :provider_id
      t.string :provider_account_name
      t.string :access_token
      t.string :access_token_secret

      t.timestamps
    end
  end
end
