class Support < ActiveRecord::Base
  validates :name,:body,:url ,presence: true
  validates :contact_no,  :numericality => { :greater_than_or_equal_to => 0 },presence: true
  validates :email, email: true,presence: true, allow_nil: true
  validates_length_of :contact_no, maximum: 18
end
