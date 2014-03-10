class AddTagIndexToPredictions < ActiveRecord::Migration
  def change
    add_index  :predictions, :tags, using: 'gin'
  end
end