FactoryGirl.define do
  factory :game do
    sequence :name do |n|
      name "Game #{n}"
    end
    
  end
  factory :user do
    sequence :email do |n|
      "dummyemail#{n}@example.com"
    end
    password "password"
    password_confirmation "password"
  end

end
