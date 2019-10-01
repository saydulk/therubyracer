class AddBlockNumberField < ActiveRecord::Migration
  def change
    add_column :deposits, :block_number, :integer unless column_exists?(:deposits, :block_number)
  end
end
