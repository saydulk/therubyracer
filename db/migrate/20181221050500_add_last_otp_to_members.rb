class AddLastOtpToMembers < ActiveRecord::Migration
  def change
    add_column :members, :last_otp, :string
  end
end
