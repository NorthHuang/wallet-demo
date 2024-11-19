class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets do |t|
      t.integer :user_id
      t.decimal :balance, precision: 12, scale: 2
      t.timestamps
    end
    add_index :wallets, :user_id, unique: true
  end
end
