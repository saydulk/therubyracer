class ChangeBodyToBeTextInSupports < ActiveRecord::Migration
  def change
    change_column :supports, :body, :text
  end
end
