class CreateSupports < ActiveRecord::Migration
  def change
    create_table :supports do |t|
      t.string :name
      t.string :body
      t.string :email
      t.text :url
      t.string :contact_no

      t.timestamps null: false
    end
  end
end
