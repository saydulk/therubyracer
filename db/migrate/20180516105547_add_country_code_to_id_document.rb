class AddCountryCodeToIdDocument < ActiveRecord::Migration
  def up
    add_column :id_documents, :country_code, :string, limit: 5
  end

  def down
    remove_column :id_documents, :country_code
  end
end
