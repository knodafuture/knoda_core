class AddIndexesToSocialAccounts < ActiveRecord::Migration
  def change
    add_index :social_accounts, [:provider_name, :provider_id]
  end
end
