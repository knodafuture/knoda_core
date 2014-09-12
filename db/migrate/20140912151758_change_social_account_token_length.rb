class ChangeSocialAccountTokenLength < ActiveRecord::Migration
  def change
    change_column :social_accounts, :access_token, :text
    change_column :social_accounts, :access_token_secret, :text
  end
end
