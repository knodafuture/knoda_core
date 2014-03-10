class RenameShownToSeenInBadges < ActiveRecord::Migration
  def change
    rename_column :badges, :shown, :seen
  end
end
