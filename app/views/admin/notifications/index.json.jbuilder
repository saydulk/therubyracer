json.array! @notifications do |notification|
  json.notification_id notification.id
  json.email Member.find_by_id(notification.entity_id).try(:email)
  json.entity_type notification.entity_type
  json.exchange notification.exchange
  json.balance notification.balance
  json.read_at notification.read_at
end