class AddDeviseIdAndTypeToBlackListToken < ActiveRecord::Migration
  def up
    add_column :blacklist_tokens, :devise_id, :string
    add_column :blacklist_tokens, :devise_type, :string
    add_column :blacklist_tokens, :in_use, :boolean
    add_column :blacklist_tokens, :email, :string
    add_index :blacklist_tokens, :devise_id
  end

  def down
    remove_index :blacklist_tokens, :devise_id
    remove_columns :blacklist_tokens, :devise_id, :devise_type, :in_use, :email
  end
end
