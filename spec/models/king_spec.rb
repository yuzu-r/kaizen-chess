require 'rails_helper'

RSpec.describe King, type: :model do
  describe "is_valid_move? returns false if move is not allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @king = King.create(position_x: 1, position_y: 2, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
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

  describe "will_be_in_check?" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
    end

    it "should return true if moving to a square that will put it in check" do
      @rook1 = Rook.create(position_x: 1, position_y: 5, game: @g, player: @g.black_player)
      @rook2 = Rook.create(position_x: 1, position_y: 3, game: @g, player: @g.black_player)
      @rook3 = Rook.create(position_x: 3, position_y: 8, game: @g, player: @g.black_player)
      @rook4 = Rook.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      expect(@king.will_be_in_check?(5, 4)).to eq true
      expect(@king.will_be_in_check?(5, 5)).to eq true
      expect(@king.will_be_in_check?(4, 5)).to eq true
      expect(@king.will_be_in_check?(3, 5)).to eq true
      expect(@king.will_be_in_check?(3, 4)).to eq true
      expect(@king.will_be_in_check?(3, 3)).to eq true
      expect(@king.will_be_in_check?(4, 3)).to eq true
      expect(@king.will_be_in_check?(5, 3)).to eq true
    end

    it "should return true if moving to a square that will put it in check by a pawn" do
      @pawn1 = Pawn.create(position_x: 6, position_y: 5, game: @g, player: @g.black_player)
      @pawn2 = Pawn.create(position_x: 6, position_y: 6, game: @g, player: @g.black_player)
      @pawn3 = Pawn.create(position_x: 5, position_y: 6, game: @g, player: @g.black_player)
      @pawn4 = Pawn.create(position_x: 2, position_y: 6, game: @g, player: @g.black_player)
      @pawn5 = Pawn.create(position_x: 2, position_y: 5, game: @g, player: @g.black_player)
      @pawn6 = Pawn.create(position_x: 2, position_y: 4, game: @g, player: @g.black_player)
      @pawn7 = Pawn.create(position_x: 5, position_y: 4, game: @g, player: @g.black_player)
      @pawn8 = Pawn.create(position_x: 6, position_y: 4, game: @g, player: @g.black_player)
      expect(@king.will_be_in_check?(5, 4)).to eq true
      expect(@king.will_be_in_check?(5, 5)).to eq true
      expect(@king.will_be_in_check?(4, 5)).to eq true
      expect(@king.will_be_in_check?(3, 5)).to eq true
      expect(@king.will_be_in_check?(3, 4)).to eq true
      expect(@king.will_be_in_check?(3, 3)).to eq true
      expect(@king.will_be_in_check?(4, 3)).to eq true
      expect(@king.will_be_in_check?(5, 3)).to eq true
    end

    it "should return true if moving to a square that will put it in check by another King" do
      @king1 = King.create(position_x: 6, position_y: 5, game: @g, player: @g.black_player)
      @king2 = King.create(position_x: 6, position_y: 6, game: @g, player: @g.black_player)
      @king3 = King.create(position_x: 5, position_y: 6, game: @g, player: @g.black_player)
      @king4 = King.create(position_x: 2, position_y: 6, game: @g, player: @g.black_player)
      @king5 = King.create(position_x: 2, position_y: 5, game: @g, player: @g.black_player)
      @king6 = King.create(position_x: 2, position_y: 4, game: @g, player: @g.black_player)
      @king7 = King.create(position_x: 5, position_y: 4, game: @g, player: @g.black_player)
      @king8 = King.create(position_x: 6, position_y: 4, game: @g, player: @g.black_player)
      expect(@king.will_be_in_check?(5, 4)).to eq true
      expect(@king.will_be_in_check?(5, 5)).to eq true
      expect(@king.will_be_in_check?(4, 5)).to eq true
      expect(@king.will_be_in_check?(3, 5)).to eq true
      expect(@king.will_be_in_check?(3, 4)).to eq true
      expect(@king.will_be_in_check?(3, 3)).to eq true
      expect(@king.will_be_in_check?(4, 3)).to eq true
      expect(@king.will_be_in_check?(5, 3)).to eq true
    end
  end
end
