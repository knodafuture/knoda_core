class AddImageUrlToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :image_url, :string, :null => true
    remove_column :activities, :comment_id
  end
end
