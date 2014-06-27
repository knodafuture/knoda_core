class AddCommentIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :comment_id, :integer, :null => true
  end
end
