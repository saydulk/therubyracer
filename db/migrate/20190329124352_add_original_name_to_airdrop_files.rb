class AddOriginalNameToAirdropFiles < ActiveRecord::Migration
  def change
    add_column :airdrop_files, :original_name, :string
  end
end
