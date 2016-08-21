require 'rails_helper'

RSpec.describe Bishop, type: :model do
  describe "is_valid_move? returns false if move is not allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @bishop = Bishop.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    
    it "returns false if moving 2 spaces up" do
      expect(@bishop.is_valid_move?(4,6)).to eq false
    end
    it "returns false if moves like a knight" do
    	expect(@bishop.is_valid_move?(6,5)).to eq false
    end
    it "returns false if it tries to move horizontally" do
    	expect(@bishop.is_valid_move?(8,4)).to eq false
    end
    it "returns false if white is in check and bishop's move doesn't resolve it", :check_block => true do
      threat = Queen.create(position_x: 5, position_y: 5, game: @g, player: @g.black_player)
      expect(@bishop.is_valid_move?(6,2)).to eq false
    end
    it "returns false if bishop's move exposes king to check" do
      threat = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.black_player)
      bishop2 = Bishop.create(position_x: 3, position_y: 1, game: @g, player: @g.white_player)
      expect(bishop2.is_valid_move?(5, 3)).to eq false
    end
  end

  describe "is_valid_move? returns true if move is allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @bishop = Bishop.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns true if moves diagonal 3 spaces" do
      expect(@bishop.is_valid_move?(7,7)).to eq true
    end 
    it "returns true if moves diagonal 2 spaces" do 
      expect(@bishop.is_valid_move?(6,2)).to eq true
    end 
    it "returns true if white is in check and move captures the attacker" do
      threat = Queen.create(position_x: 5, position_y: 5, game: @g, player: @g.black_player)
      expect(@bishop.is_valid_move?(5,5)).to eq true
    end
  end  
end