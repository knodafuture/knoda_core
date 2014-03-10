class AddHiddenToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :hidden, :boolean, :default => false
  end
end
