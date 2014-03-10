class SplitActivityTitleBody < ActiveRecord::Migration
  def change
    rename_column :activities, :body, :prediction_body
    add_column :activities, :title, :text
  end
end
