class CreateWithdrawals < ActiveRecord::Migration[7.0]
  def change
    create_table :withdrawals do |t|
      t.integer :user_id
      t.decimal :amount, precision: 12, scale: 2
      t.string :platform
      t.string  :order_no
      t.string :status
      t.json :metadata
      t.timestamps
    end
    add_index :withdrawals, [:platform, :order_no], unique: true
    add_index :withdrawals, :user_id
  end
end
