class RemoveUnfinishedFromPrediction < ActiveRecord::Migration
  def change
    remove_column :predictions, :unfinished
  end
end
