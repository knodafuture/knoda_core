class AddShownToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :shown, :boolean, :default => false
  end
end
