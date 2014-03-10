class ExpandCommentText < ActiveRecord::Migration
  def change
    change_column :comments, :text, :string, :limit => 300
  end
end
