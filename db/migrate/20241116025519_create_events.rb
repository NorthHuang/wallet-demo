class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.references :eventable, polymorphic: true, index: true
      t.string :event_type
      t.integer :related_event_id
      t.integer :user_id
      t.timestamps
    end
    add_index :events, :user_id
    add_index :events, :related_event_id
    add_index :events, :event_type
  end
end
