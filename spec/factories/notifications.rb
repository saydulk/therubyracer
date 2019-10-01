FactoryBot.define do
  factory :notification do
    entity_type { 1 }
    entity_id { 1 }
    exchange { "MyString" }
    balance { 1.5 }
    read_at { "2018-10-08 18:56:36" }
  end
end
