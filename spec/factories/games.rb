FactoryGirl.define do
  factory :game do
    sequence(:name) {|n| "Game #{n}"}
    white_player

    factory :joined_game do
      black_player
    end
  end

  factory :user, aliases: [:white_player, :black_player] do
    sequence(:email) {|n| "dummyemail#{n}@example.com"}
    password "password"
    password_confirmation "password"
  end

end
