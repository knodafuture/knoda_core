class SignupSource < ActiveRecord::Migration
  def change
    add_column :users, :signup_source, :string
  end
end
