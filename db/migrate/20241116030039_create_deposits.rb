class CreateDeposits < ActiveRecord::Migration[7.0]
  def change
    create_table :deposits do |t|
      t.integer :user_id
      t.decimal :amount, precision: 12, scale: 2
      t.string :platform
      t.string  :order_no
      t.json :metadata
      t.timestamps
    end
    add_index :deposits, [:platform, :order_no], unique: true
    add_index :deposits, :user_id
  end
end
