class Notification < ActiveRecord::Base
  scope :unread, ->{where read_at: nil}
  enum entity_type: { member: 0, client: 1 }
end
