class SetDefaultAttributesForUser < ActiveRecord::Migration
  def change
    change_column_default :users, :admin, false
    change_column_default :users, :notifications, true
  end
end
