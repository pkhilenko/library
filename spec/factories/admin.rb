FactoryBot.define do
  factory :admin, class: 'User' do
    admin { true }
    first_name { 'Piotr' }
    last_name { 'Jaworski' }
    sequence(:email) { |i| "my-email-#{i}@mail.com" }
  end
end
