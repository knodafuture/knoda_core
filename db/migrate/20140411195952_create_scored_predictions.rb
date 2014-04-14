class CreateScoredPredictions < ActiveRecord::Migration
  def change
    create_table :scored_predictions do |t|
      t.integer :prediction_id
      t.string :body
      t.datetime :expires_at
      t.string :username
      t.string :avatar_image
      t.integer :agree_percentage
      t.timestamps      
    end
  end
end
