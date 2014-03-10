class AddGroupToPrediction < ActiveRecord::Migration
  def change
    add_column :predictions, :group_id, :integer
  end
end
