class CreateTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.decimal :amount, precision: 10, scale: 2
      t.json :metadata
      t.timestamps
    end
    add_index :transfers, :from_user_id
    add_index :transfers, :to_user_id
  end
end
