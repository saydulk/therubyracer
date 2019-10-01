class CreateAirdropFiles < ActiveRecord::Migration
  def change
    create_table :airdrop_files do |t|
      t.references :member, index: true
      t.boolean :is_used, default: false
      t.timestamps null: false
    end
  end
end
