class ChangeContactTypeIntegerToString < ActiveRecord::Migration
  def change
    change_column :id_documents, :contact_no, :string

  end
end
