FactoryBot.define do
  factory :commission do
    modifiable_type { "MyString" }
    currency { "MyString" }
    amount { 1.5 }
  end
end
