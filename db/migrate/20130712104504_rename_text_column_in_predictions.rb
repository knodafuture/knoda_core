class RenameTextColumnInPredictions < ActiveRecord::Migration
  def change
    rename_column :predictions, :text, :body
  end
end
