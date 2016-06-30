require 'rails_helper'

RSpec.describe King, type: :model do
  describe "is_valid_move? returns false if move is not allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @king = King.create(position_x: 1, position_y: 2, game: @g, player: @g.white_player)
    end
   
    it "returns true if moving 1 space up" do
      expect(@king.is_valid_move?(1,3)).to eq true
    end
    it "returns false if moves multiple spaces" do
    	expect(@king.is_valid_move?(1,6)).to eq false
    end
    it "returns true if moves diagonal 1 space" do
    	expect(@king.is_valid_move?(2,3)).to eq true
    end 
    it "returns true if it tries to move horizontally" do
    	expect(@king.is_valid_move?(2,2)).to eq true
    end
    
    # castling: is_valid_move?
    it "returns false if attempting castle and king has moved" do
      @king.move_count = 3
      @king.position_x = 5
      @king.position_y = 1

      @rook = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)
      
      expect(@king.is_valid_move?(3, 1)).to eq false
    end
    it "returns false if attempting castle and rook has moved" do
      @king.position_x = 5
      @king.position_y = 1
      
      @rook = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player, move_count: 1)
      
      expect(@king.is_valid_move?(3, 1)).to eq false
    end
    it "returns true if attempting castle to right rook and no moves and no obstructions" do
      @king.position_x = 5
      @king.position_y = 1

      @rook = Rook.create(position_x: 8, position_y: 1, game: @g, player: @g.white_player)

      expect(@king.is_valid_move?(7, 1)).to eq true
    end
    it "returns true if attempting castle to left rook and no moves and no obstructions" do
      @king.move_count = 0
      @king.position_x = 5
      @king.position_y = 1

      @rook = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)

      expect(@king.is_valid_move?(3, 1)).to eq true
    end
    it "returns false if attempting castle and there is a piece in the way" do
      @king.move_count = 0
      @king.position_x = 5
      @king.position_y = 1

      @rook = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)
      @queen = Queen.create(position_x: 4, position_y: 1, game: @g, player: @g.white_player)
      expect(@king.is_valid_move?(3, 1)).to eq false
    end
    it "should return false if you try to castle and there is no rook" do
      expect(@king.is_valid_move?(3, 1)).to eq false
    end

    it "should return false when king is in check" do
      @king.move_count = 0
      @king.position_x = 5
      @king.position_y = 1

      @rook = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)
      @queen = Queen.create(position_x: 5, position_y: 3, game: @g, player: @g.black_player)
      expect(@king.is_valid_move?(3, 1)).to eq false
    end

    it "should return false when castling moves king through check" do
      @king.move_count = 0
      @king.position_x = 5
      @king.position_y = 1

      @rook = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)
      @queen = Queen.create(position_x: 4, position_y: 3, game: @g, player: @g.black_player)
      expect(@king.is_valid_move?(3, 1)).to eq false
    end

    it "should return false when castling moves king into check" do
      @king.move_count = 0
      @king.position_x = 5
      @king.position_y = 1

      @rook = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)
      @enemy_rook = Rook.create(position_x: 3, position_y: 8, game: @g, player: @g.black_player)
      expect(@king.is_valid_move?(3, 1)).to eq false
    end

  end
end
