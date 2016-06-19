require 'rails_helper'

RSpec.describe Rook, type: :model do
  describe "is_valid_move? returns false if move is not allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @rook = Rook.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end

    
    it "returns false if moving 2 spaces up" do
      expect(@rook.is_valid_move?(4,6)).to eq true
    end
    it "returns false if moves like a knight" do
    	expect(@rook.is_valid_move?(6,5)).to eq false
    end
    it "returns true if moves diagonal 3 spaces" do
    	expect(@rook.is_valid_move?(7,7)).to eq false
    end 
    it "returns true if moves diagonal 2 spaces" do
    	expect(@rook.is_valid_move?(6,2)).to eq false
    end 
    it "returns false if it tries to move horizontally" do
    	expect(@rook.is_valid_move?(8,4)).to eq true
    end
   
  end
end