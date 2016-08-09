require 'rails_helper'

RSpec.describe Rook, type: :model do
  describe "is_valid_move? returns false if move is not allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @rook = Rook.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
    end  
    it "returns false if moves like a knight" do
    	expect(@rook.is_valid_move?(6,5)).to eq false
    end
    it "returns false if moves diagonal 3 spaces" do
    	expect(@rook.is_valid_move?(7,7)).to eq false
    end 
    it "returns false if moves diagonal 2 spaces" do
    	expect(@rook.is_valid_move?(6,2)).to eq false
    end
    it "returns false if black is in check and rook's move doesn't resolve it", :check_block => true do
      threat = Queen.create(position_x: 5, position_y: 5, game: @g, player: @g.white_player)
      expect(@rook.is_valid_move?(4,2)).to eq false
    end
  end
  describe "is_valid_move? returns true if move is allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @rook = Rook.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
    end  
    it "returns true if moving 2 spaces up" do
      expect(@rook.is_valid_move?(4,6)).to eq true
    end
    it "returns true if it tries to move horizontally" do
      expect(@rook.is_valid_move?(8,4)).to eq true
    end
    it "returns true if black is in check and the rook blocks the attacking piece" do
      threat = Queen.create(position_x: 5, position_y: 5, game: @g, player: @g.white_player)
      rook2 = Rook.create(position_x: 1, position_y: 6, game: @g, player: @g.black_player)
      expect(rook2.is_valid_move?(5,6)).to eq true
    end
  end
end