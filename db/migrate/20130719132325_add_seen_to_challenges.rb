class AddSeenToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :seen, :boolean, :default => false
  end
end
