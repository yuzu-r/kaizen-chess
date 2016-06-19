require 'rails_helper'

RSpec.describe Knight, type: :model do
  describe "is_valid_move? returns false if move is not allowed" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @knight = Knight.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
    end

    
    it "returns false if moving 2 spaces up" do
      expect(@knight.is_valid_move?(4,6)).to eq false
    end
    it "returns false if moves like a knight" do
    	expect(@knight.is_valid_move?(6,5)).to eq true
    end
    it "returns false if moves like a knight" do
    	expect(@knight.is_valid_move?(2,3)).to eq true
    end
    it "returns false if moves like a knight" do
    	expect(@knight.is_valid_move?(6,3)).to eq true
    end
    it "returns true if moves diagonal 3 spaces" do
    	expect(@knight.is_valid_move?(7,7)).to eq false
    end 
    it "returns true if moves diagonal 2 spaces" do
    	expect(@knight.is_valid_move?(6,2)).to eq false
    end 
    it "returns false if it tries to move horizontally" do
    	expect(@knight.is_valid_move?(8,4)).to eq false
    end
   
  end
end