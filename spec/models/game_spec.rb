require 'rails_helper'

RSpec.describe Game, type: :model do
  it "can be created without a black player" do
    game_count = Game.count
    expect(FactoryGirl.create(:game)).to be_valid
    expect(Game.count).to eq game_count+1
  end

  it "has a valid factory with both players set" do
    game_count = Game.count
    g=FactoryGirl.create(:joined_game)
    expect(g).to be_valid
    expect(Game.count).to eq game_count+1
    expect(g.black_player).to_not be nil
  end

end
