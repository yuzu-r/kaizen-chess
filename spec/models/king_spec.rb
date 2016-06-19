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
   
  end
end
