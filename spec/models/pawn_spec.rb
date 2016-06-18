require 'rails_helper'

RSpec.describe Pawn, type: :model do
  
  describe "is_valid_move? returns false if path is not blocked" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
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
    it "prevent moving two spaces forward for first move if it has already moved" do
    	expect(@wp2.is_valid_move?(2,5)).to eq false
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

end
