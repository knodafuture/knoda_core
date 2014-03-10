class AddBsToChallenge < ActiveRecord::Migration
  def change
    add_column :challenges, :bs, :boolean, :default => false
  end
end
