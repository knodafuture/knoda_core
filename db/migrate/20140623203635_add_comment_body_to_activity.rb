class AddCommentBodyToActivity < ActiveRecord::Migration
  def change
  add_column :activities, :comment_body, :text
  end
end
