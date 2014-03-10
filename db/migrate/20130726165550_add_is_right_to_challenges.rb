class AddIsRightToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :is_right, :boolean, :default => false
  end
end
