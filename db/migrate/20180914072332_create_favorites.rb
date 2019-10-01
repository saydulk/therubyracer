class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer :member_id, null: false
      t.string :market_id, null: false, limit: 20

      t.timestamps null: false
    end
  end
end
