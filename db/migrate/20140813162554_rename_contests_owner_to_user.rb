class RenameContestsOwnerToUser < ActiveRecord::Migration
  def change
    rename_column :contests, :owner_id, :user_id
  end
end
