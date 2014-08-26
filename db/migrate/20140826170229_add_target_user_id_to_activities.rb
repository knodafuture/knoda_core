class AddTargetUserIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :target_user_id, :integer, :null => true
  end
end
