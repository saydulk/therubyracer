class AddFieldsToIdDocuments < ActiveRecord::Migration
  def change
    add_column :id_documents, :middle_name, :string
    add_column :id_documents, :last_name, :string
    add_column :id_documents, :place_of_birth, :string
    add_column :id_documents, :state, :string
    add_column :id_documents, :gender, :string
    add_column :id_documents, :contact_no, :integer
  end
end
