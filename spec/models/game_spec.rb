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
      g=FactoryGirl.create(:joined_game)
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

  describe "is_in_check? returns true if player is in check" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
    end   
    it "is true if white player is in check by pawn" do
      white_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
      black_pawn = Pawn.create(position_x: 3, position_y: 5, game: @g, player: @g.black_player)
      expect(@g.is_in_check?(@g.white_player)).to eq true
    end
    it "is true if black player is in check by rook" do
      black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      white_rook = Rook.create(position_x: 1, position_y: 4, game: @g, player: @g.white_player)
      expect(@g.is_in_check?(@g.black_player)).to eq true
    end
    it "is true if black player is in check by knight" do
      black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      white_knight = Knight.create(position_x: 6, position_y: 5, game: @g, player: @g.white_player)
      expect(@g.is_in_check?(@g.black_player)).to eq true
    end
  end

  describe "is_in_check? false if player is not in check" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
    end   
    it "is false if white player can't capture black king (obstructed)" do
      black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      white_queen = Queen.create(position_x: 1, position_y: 4, game: @g, player: @g.white_player)
      black_pawn = Pawn.create(position_x: 3, position_y: 4, game: @g, player: @g.black_player)
      expect(@g.is_in_check?(@g.black_player)).to eq false
    end

    it "is false if black player can't capture white king (no pieces in range)" do
      white_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
      black_bishop = Bishop.create(position_x: 3, position_y: 4, game: @g, player: @g.black_player)
      black_pawn = Pawn.create(position_x: nil, position_y: nil, is_active: false, game: @g, player: @g.black_player)
      black_pawn2 = Pawn.create(position_x: 4, position_y: 5, game: @g, player: @g.black_player)
      black_king = King.create(position_x: 1, position_y: 1, game: @g, player: @g.black_player)
      expect(@g.is_in_check?(@g.black_player)).to eq false
    end

  end
end
