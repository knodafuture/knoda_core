class RenameIsPositiveColumnInChallenges < ActiveRecord::Migration
  def change
    rename_column :challenges, :is_positive, :agree
  end
end
