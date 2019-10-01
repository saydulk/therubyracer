class CreateBlacklistTokens < ActiveRecord::Migration
  def change
    create_table :blacklist_tokens do |t|
      t.text :token

      t.timestamps null: false
    end
  end
end
