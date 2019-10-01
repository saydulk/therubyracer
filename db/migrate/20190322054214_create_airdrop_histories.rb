class CreateAirdropHistories < ActiveRecord::Migration
  def change
    create_table :airdrop_histories do |t|
      t.references :withdraw, index: true, foreign_key: true
      t.references :airdrop_file, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
