class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :ip_address
      t.integer :member_id
      t.datetime :created_at

      t.timestamps null: false
    end
  end
end
