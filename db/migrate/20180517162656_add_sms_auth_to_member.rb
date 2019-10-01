class AddSmsAuthToMember < ActiveRecord::Migration
  def change
    add_column :members, :sms_auth, :integer, default: 0
  end
end
