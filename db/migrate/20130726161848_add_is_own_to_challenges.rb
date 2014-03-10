class AddIsOwnToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :is_own, :boolean, :default => false
  end
end
