class AddTagArrayToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :tags, :string, :array => true, :default => []
  end
end
