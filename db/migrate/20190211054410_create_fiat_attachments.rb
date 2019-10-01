class CreateFiatAttachments < ActiveRecord::Migration
  def change
    create_table :fiat_attachments do |t|
      t.string :avatar
      t.references :deposit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
