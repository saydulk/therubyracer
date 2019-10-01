FactoryBot.define do
  factory :bank_details do
    name { "MyString" }
    bank_name { "MyString" }
    account_number { "MyString" }
    ifsc_code { "MyString" }
    state { "MyString" }
    member { nil }
  end
end
