FactoryBot.define do
  factory :payment do
    user { nil }
    price { "" }
    status { 1 }
    reference { "MyString" }
    payment_method { "" }
    response_id { "MyString" }
    full_response { "" }
  end
end
