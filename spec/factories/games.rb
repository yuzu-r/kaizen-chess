FactoryGirl.define do
  factory :game do
    sequence :name do |n|
      name "Game #{n}"
    end
    white_player
  end
  factory :user, aliases: [:white_player, :black_player] do
    sequence :email do |n|
      "dummyemail#{n}@example.com"
    end
    password "password"
    password_confirmation "password"
  end

end
