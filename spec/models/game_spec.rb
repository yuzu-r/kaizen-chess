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

  context "active_player validation" do
    it "allows active_player to be white player" do
      g=FactoryGirl.create(:game)
      g.active_player_id = g.white_player_id
      expect(g).to be_valid
      expect(g.active_player_id).to eq g.white_player_id
    end

    it "allows active_player to be black player" do
      g=FactoryGirl.create(:joined_game)
      g.active_player_id = g.black_player_id
      expect(g).to be_valid
      expect(g.active_player_id).to eq g.black_player_id
    end

    it "does not allow active_player to be some third player" do
      g=FactoryGirl.create(:joined_game)
      u= FactoryGirl.create(:user)
      g.active_player_id = u.id
      expect(g).to_not be_valid
    end
  end

end
