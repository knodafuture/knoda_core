class ChangeExpiresAtInPredictions < ActiveRecord::Migration
  def change
    change_column :predictions, :expires_at, :datetime
  end
end
