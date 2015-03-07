class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :account_name
      t.integer :account_balance
      t.integer :account_number

      t.timestamps null: false
    end
  end
end
