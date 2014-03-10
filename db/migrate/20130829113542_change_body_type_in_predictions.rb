class ChangeBodyTypeInPredictions < ActiveRecord::Migration
  def change
  	change_column :predictions, :body, :text, :limit => 1000
  end
end
