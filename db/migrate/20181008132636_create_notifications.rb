class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :entity_type
      t.integer :entity_id
      t.string :exchange
      t.float :balance
      t.datetime :read_at

      t.timestamps null: false
    end
  end
end
