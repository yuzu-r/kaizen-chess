require 'rails_helper'

RSpec.describe Pawn, type: :model do
  
  describe "is_valid_move? returns false if move is not allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @wp1 = Pawn.create(position_x: 1, position_y: 2, game: @g, player: @g.white_player)
      @wp2 = Pawn.create(position_x: 2, position_y: 3, game: @g, player: @g.white_player, move_count: 3)
      @bp1 = Pawn.create(position_x: 2, position_y: 7, game: @g, player: @g.black_player)
      @bp2 = Pawn.create(position_x: 1, position_y: 7, game: @g, player: @g.black_player, move_count: 1)
    end

    # white player
    it "returns true if moving 1 space" do
      expect(@wp1.is_valid_move?(1,3)).to eq true
    end
    it "returns false if moves 1 space backwards" do
    	expect(@wp1.is_valid_move?(1,1)).to eq false
    end
    it "return false if it moves two spaces forward for first move if it has already moved" do
    	expect(@wp2.is_valid_move?(2,5)).to eq false
    end 
    it "returns false if it tries to move horizontally" do
    	expect(@wp2.is_valid_move?(3,3)).to eq false
    end
    

    # black player
    it "returns true if black piece moves once space forward" do
    	expect(@bp1.is_valid_move?(2,6)).to eq true
    end
    it "returns true if black piece moves two spaces forward if it hasn't yet moved" do
    	expect(@bp1.is_valid_move?(2,5)).to eq true
    end
    it "returns false if it tries to move backwards" do
    	expect(@bp2.is_valid_move?(1,8)).to eq false
    end
  end

  describe "is_valid_move? evaluates whether move resolves king in check" do
    it "returns false if vertical move fails to resolve a king in check" do
      g = FactoryGirl.create(:joined_game)
      # note: the kings need to be defined in the game now that we check for checks
      white_king = King.create(position_x: 5, position_y: 1, game: g, player: g.white_player)
      black_king = King.create(position_x: 5, position_y: 8, game: g, player: g.black_player)
      threat = Rook.create(position_x: 5, position_y: 6, game: g, player: g.white_player)
      pawn = Pawn.create(position_x: 4, position_y: 7, game: g, player: g.black_player)
      expect(pawn.is_valid_move?(4,6)).to eq false
    end
    it "returns false if capture fails to resolve a king in check" do
      g = FactoryGirl.create(:joined_game)
      white_king = King.create(position_x: 5, position_y: 1, game: g, player: g.white_player)
      black_king = King.create(position_x: 5, position_y: 8, game: g, player: g.black_player)
      threat = Rook.create(position_x: 5, position_y: 6, game: g, player: g.white_player)
      threat2 = Queen.create(position_x: 3, position_y: 6, game: g, player: g.white_player)
      pawn = Pawn.create(position_x: 4, position_y: 7, game: g, player: g.black_player)
      expect(pawn.is_valid_move?(3,6)).to eq false
    end
    it "returns true if short vertical move blocks an attacker from the king" do
      g = FactoryGirl.create(:joined_game)
      white_king = King.create(position_x: 5, position_y: 1, game: g, player: g.white_player)
      black_king = King.create(position_x: 5, position_y: 7, game: g, player: g.black_player)
      threat = Queen.create(position_x: 3, position_y: 5, game: g, player: g.white_player)
      pawn = Pawn.create(position_x: 4, position_y: 7, game: g, player: g.black_player)
      expect(pawn.is_valid_move?(4,6)).to eq true
    end    
    it "returns true if long vertical move blocks an attacker from the king" do
      g = FactoryGirl.create(:joined_game)
      white_king = King.create(position_x: 5, position_y: 4, game: g, player: g.white_player)
      black_king = King.create(position_x: 5, position_y: 8, game: g, player: g.black_player)
      threat = Rook.create(position_x: 1, position_y: 4, game: g, player: g.black_player)
      pawn = Pawn.create(position_x: 4, position_y: 2, game: g, player: g.white_player)
      expect(pawn.is_valid_move?(4,4)).to eq true
    end
    it "returns true if capture removes an attacker" do
      g = FactoryGirl.create(:joined_game)
      white_king = King.create(position_x: 5, position_y: 1, game: g, player: g.white_player)
      black_king = King.create(position_x: 5, position_y: 8, game: g, player: g.black_player)
      threat = Rook.create(position_x: 5, position_y: 6, game: g, player: g.white_player)
      pawn = Pawn.create(position_x: 4, position_y: 7, game: g, player: g.black_player)
      expect(pawn.is_valid_move?(5,6)).to eq true
    end
  end


  describe "is_valid_enpassant?" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)    
    end

    it "returns false if en passant does not resolve king in check", :failing => true do
      g = FactoryGirl.create(:joined_game)
      white_king = King.create(position_x: 5, position_y: 1, game: g, player: g.white_player)
      black_king = King.create(position_x: 5, position_y: 8, game: g, player: g.black_player)
      threat = Knight.create(position_x: 4, position_y: 3, game: g, player: g.black_player)
      en_p_target = Pawn.create(position_x: 1, position_y: 5, game: g, player: g.black_player, move_count: 1)
      g.update_attributes(last_moved_piece: en_p_target)
      pawn = Pawn.create(position_x: 2, position_y: 5, game: g, player: g.white_player)
      expect(pawn.is_valid_move?(1,6)).to eq false
    end
    it "returns true if king in check and en passant captures attacker (white)" do
      g = FactoryGirl.create(:joined_game)
      white_king = King.create(position_x: 3, position_y: 4, game: g, player: g.white_player) #415
      black_king = King.create(position_x: 5, position_y: 8, game: g, player: g.black_player)
      en_p_target = Pawn.create(position_x: 4, position_y: 5, game: g, player: g.black_player, move_count: 1) #396
      g.update_attributes(last_moved_piece: en_p_target)
      pawn = Pawn.create(position_x: 5, position_y: 5, game: g, player: g.white_player) #389
      expect(pawn.is_valid_move?(4,6)).to eq true
    end
    it "returns true if king in check and en passant captures attacker (black king check)" do
      g = FactoryGirl.create(:joined_game)
      white_king = King.create(position_x: 1, position_y: 1, game: g, player: g.white_player)
      black_king = King.create(position_x: 5, position_y: 5, game: g, player: g.black_player)
      en_p_threat = Pawn.create(position_x: 4, position_y: 4, game: g, player: g.white_player, move_count: 1)
      g.update_attributes(last_moved_piece: en_p_threat)
      pawn = Pawn.create(position_x: 3, position_y: 4, game: g, player: g.black_player)
      expect(pawn.is_valid_move?(4,3)).to eq true
    end
    it "returns true if moving diagonally right after white enemy player moves two spaces" do
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @bp1 = Pawn.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      @wp1 = Pawn.create(position_x: 5, position_y: 4, game: @g, player: @g.white_player, move_count: 1)
      @g.update_attributes(last_moved_piece: @wp1)
      expect(@bp1.is_valid_enpassant?(5,3)).to eq true
    end
    it "returns true if moving diagonally left after white enemy player moves two spaces" do
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @bp1 = Pawn.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      @wp1 = Pawn.create(position_x: 3, position_y: 4, game: @g, player: @g.white_player, move_count: 1)
      @g.update_attributes(last_moved_piece: @wp1)
      expect(@bp1.is_valid_enpassant?(3,3)).to eq true
    end
    it "returns true if moving diagonally right after black enemy player moves two spaces" do
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @bp1 = Pawn.create(position_x: 4, position_y: 5, game: @g, player: @g.black_player, move_count: 1)
      @wp1 = Pawn.create(position_x: 3, position_y: 5, game: @g, player: @g.white_player)
      @g.update_attributes(last_moved_piece: @bp1)
      expect(@wp1.is_valid_enpassant?(4,6)).to eq true
    end
    it "returns true if moving diagonally left after black enemy player moves two spaces" do
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @bp1 = Pawn.create(position_x: 4, position_y: 5, game: @g, player: @g.black_player, move_count: 1)
      @wp1 = Pawn.create(position_x: 5, position_y: 5, game: @g, player: @g.white_player)
      @g.update_attributes(last_moved_piece: @bp1)
      expect(@wp1.is_valid_enpassant?(4,6)).to eq true
    end
    it "returns false if not immediately moving after white enemy player moves two spaces" do
      # note: the kings need to be defined in the game now that we check for checks
      @white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @bp1 = Pawn.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      @wp1 = Pawn.create(position_x: 5, position_y: 4, game: @g, player: @g.white_player, move_count: 1)
      @g.update_attributes(last_moved_piece: @bp1)
      expect(@bp1.is_valid_enpassant?(5,3)).to eq false
    end
  end

end
