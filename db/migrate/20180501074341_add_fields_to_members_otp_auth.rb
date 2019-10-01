class AddFieldsToMembersOtpAuth < ActiveRecord::Migration
  def change
    add_column :members, :otp_secret_key, :string
    add_column :members, :otp_module, :integer, default: 0
  end
end
