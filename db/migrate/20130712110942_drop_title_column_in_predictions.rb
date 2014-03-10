class DropTitleColumnInPredictions < ActiveRecord::Migration
  def change
    remove_column :predictions, :title
  end
end
