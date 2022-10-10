FactoryBot.define do
  factory :admin_user do
    email { "w@rst-it.com" }
    password { "awesomepassword" }
    password_confirmation { "awesomepassword" }
  end

end
