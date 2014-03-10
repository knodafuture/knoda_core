class RenameClosedAsToOutcomeInPredictions < ActiveRecord::Migration
  def change
    rename_column :predictions, :closed_as, :outcome
  end
end
