class CreateUserAgreements < ActiveRecord::Migration
  def change
    create_table :user_agreements do |t|
      t.integer "user_id"
      t.string "agreement_type"
      t.timestamps
    end
  end
end
