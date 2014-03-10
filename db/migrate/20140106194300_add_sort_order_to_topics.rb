class AddSortOrderToTopics < ActiveRecord::Migration
  def change
  	add_column :topics, :sort_order, :integer, :default => 99
  end
end
