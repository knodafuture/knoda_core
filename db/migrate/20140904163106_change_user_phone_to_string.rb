class ChangeUserPhoneToString < ActiveRecord::Migration
  def change
    change_column :users, :phone, :string
  end
end
