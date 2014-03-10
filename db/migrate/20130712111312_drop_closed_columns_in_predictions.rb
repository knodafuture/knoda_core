class DropClosedColumnsInPredictions < ActiveRecord::Migration
  def change
    remove_column :predictions, :closed
    remove_column :predictions, :closed_at
  end
end
