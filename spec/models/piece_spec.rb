require 'rails_helper'

RSpec.describe Piece, type: :model do
  describe "is_valid_capture? returns true if enemy is on destination" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x:4, position_y: 4, game: @g, player: @g.white_player)
    end      
    it "returns true if enemy on destination" do
      enemy = Pawn.create(position_x:4,position_y:7,game: @g, player: @g.black_player)
      expect(@q.is_valid_capture?(4,7)).to eq true
    end

    it "returns false if no piece is on destination" do
      expect(@q.is_valid_capture?(4,6)).to eq false
    end

    it "returns false if player's own piece is on destination" do
      friend = Pawn.create(position_x: 4, position_y: 2, game: @g, player: @g.white_player)
      expect(@q.is_valid_capture?(4,2)).to eq false
    end
  end

  it "returns true when a non-pawn captures an enemy" do
    g = FactoryGirl.create(:joined_game)
    q = Queen.create(position_x: 4, position_y: 4, game: g, player: g.white_player)
    enemy = Pawn.create(position_x: 4, position_y: 7, game: g, player: g.black_player)
    expect(q.capture(4,7)).to eq true
    enemy.reload
    expect(enemy.is_active).to eq false
    expect(enemy.position_x).to eq nil
  end

  it "returns false if non-pawn capture fails" do
    g = FactoryGirl.create(:joined_game)
    q = Queen.create(position_x: 4, position_y: 4, game: g, player: g.white_player)
    friend = Pawn.create(position_x: 4, position_y: 3, game: g, player: g.white_player)
    expect(q.capture(4,3)).to eq false
    q.reload
    expect(q.position_y).to eq 4
  end

  describe "is_valid_capture returns true when a pawn captures an enemy" do
    it "returns true for a white pawn capturing" do
      g = FactoryGirl.create(:joined_game)
      p = Pawn.create(position_x: 4, position_y: 4, game: g, player: g.white_player)
      enemy = Queen.create(position_x: 3, position_y: 5, game: g, player: g.black_player)
      expect(p.capture(3,5)).to eq true
      enemy.reload
      expect(enemy.is_active).to eq false
    end

    it "returns true for a black pawn capturing" do
      g = FactoryGirl.create(:joined_game)
      p = Pawn.create(position_x: 4, position_y: 4, game: g, player: g.black_player)
      enemy = Queen.create(position_x: 3, position_y: 3, game: g, player: g.white_player)
      expect(p.capture(3,3)).to eq true
      enemy.reload
      expect(enemy.is_active).to eq false
    end
  end

  describe "is_valid_capture returns false if pawn capture fails" do
    it "returns false if move is not diagonal and one space" do
      g = FactoryGirl.create(:joined_game)
      p = Pawn.create(position_x: 4, position_y: 4, game: g, player: g.black_player)
      enemy = Queen.create(position_x: 3, position_y: 2, game: g, player: g.white_player)
      expect(p.capture(3,2)).to eq false
    end

    it "returns false if there is no enemy present" do
      g = FactoryGirl.create(:joined_game)
      p = Pawn.create(position_x: 4, position_y: 4, game: g, player: g.black_player)
      expect(p.capture(3,3)).to eq false      
    end

    it "returns false if white pawn tries to capture southwards" do
      g = FactoryGirl.create(:joined_game)
      p = Pawn.create(position_x: 4, position_y: 4, game: g, player: g.white_player)
      enemy = Queen.create(position_x: 3, position_y: 3, game: g, player: g.black_player)
      expect(p.capture(3,3)).to eq false
    end

    it "returns false if black pawn tries to capture southwards" do
      g = FactoryGirl.create(:joined_game)
      p = Pawn.create(position_x: 4, position_y: 4, game: g, player: g.black_player)
      enemy = Queen.create(position_x: 5, position_y: 5, game: g, player: g.white_player)
      expect(p.capture(5,5)).to eq false
    end
  end

  describe "is_obstructed? returns false if path is not blocked" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns false if moving west and no piece in the way" do
      expect(@q.is_obstructed?(1,4)).to eq false
    end
    it "returns false if moving east and no piece in the way" do
      expect(@q.is_obstructed?(8,4)).to eq false
    end
    it "returns false if moving north and no piece in the way" do
      expect(@q.is_obstructed?(4,8)).to eq false
    end
    it "returns false if moving south and no piece in the way" do
      expect(@q.is_obstructed?(4,1)).to eq false
    end
    it "returns false if moving northwest and nothing in the way" do
      expect(@q.is_obstructed?(1,7)).to eq false
    end
    it "returns false if moving northeast and nothing in the way" do
      expect(@q.is_obstructed?(8,8)).to eq false
    end
    it "returns false if moving southwest and nothing in the way" do
      expect(@q.is_obstructed?(1,1)).to eq false
    end
    it "returns false if moving southeast and nothing in the way" do
      expect(@q.is_obstructed?(7,1)).to eq false
    end
  end
  describe "is_obstructed? returns false if way is clear and enemy piece on destination" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns false if moving west and enemy piece on destination" do
      @enemy = Pawn.create(position_x: 1, position_y: 4, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(1,4)).to eq false
    end
    it "returns false if moving east and enemy piece on destination" do
      @enemy = Pawn.create(position_x: 8, position_y: 4, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(8,4)).to eq false      
    end
    it "returns false if moving north and enemy piece on destination" do
      @enemy = Pawn.create(position_x: 4, position_y: 8, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(4,8)).to eq false      
    end
    it "returns false if moving south and enemy piece on destination" do
      @enemy = Pawn.create(position_x: 4, position_y: 1, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(4,1)).to eq false
    end
    it "returns false if moving northwest and enemy on destination" do
      @enemy = Pawn.create(position_x: 1, position_y: 7, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(1,7)).to eq false
    end
    it "returns false if moving northeast and enemy on destination" do
      @enemy = Pawn.create(position_x: 8, position_y: 8, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(8,8)).to eq false
    end
    it "returns false if moving southwest and enemy on destination" do
      @enemy = Pawn.create(position_x: 1, position_y: 1, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(1,1)).to eq false
    end
    it "returns false if moving southeast and enemy on destination" do
      @enemy = Pawn.create(position_x: 7, position_y: 1, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(7,1)).to eq false
    end    
  end
  describe "is_obstructed? returns true if way is clear but an ally is on destination" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns true if moving west and friend is on destination" do
      @friend = Pawn.create(position_x: 1, position_y: 4, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(1,4)).to eq true
    end
    it "returns true if moving east and friend is on destination" do
      @friend = Pawn.create(position_x: 8, position_y: 4, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(8,4)).to eq true
    end
    it "returns true if moving north and friend is on destination" do
      @friend = Pawn.create(position_x: 4, position_y: 8, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(4,8)).to eq true
    end
    it "returns true if moving south and friend is on destination" do
      @friend = Pawn.create(position_x: 4, position_y: 1, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(4,1)).to eq true
    end           
    it "returns true if moving northwest and friend is on destination" do
      @friend = Pawn.create(position_x: 1, position_y: 7, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(1,7)).to eq true
    end
    it "returns true if moving northeast and friend is on destination" do
      @friend = Pawn.create(position_x: 8, position_y: 8, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(8,8)).to eq true
    end
    it "returns true if moving southwest and friend is on destination" do
      @friend = Pawn.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(1,1)).to eq true
    end
    it "returns true if moving southeast and friend is on destination" do
      @friend = Pawn.create(position_x: 7, position_y: 1, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(7,1)).to eq true
    end           
  end
  # range test - blocked next to starting point
  describe "is_obstructed? returns true if a piece is next to start" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns true if moving west and friend is in the way" do
      @friend = Pawn.create(position_x: 3, position_y: 4, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(1,4)).to eq true
    end
    it "returns true if moving east and friend is in the way" do
      @friend = Pawn.create(position_x: 5, position_y: 4, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(8,4)).to eq true
    end
    it "returns true if moving north and friend is in the way" do
      @friend = Pawn.create(position_x: 4, position_y: 5, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(4,8)).to eq true
    end
    it "returns true if moving south and friend is in the way" do
      @friend = Pawn.create(position_x: 4, position_y: 3, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(4,1)).to eq true
    end           
    it "returns true if moving northwest and friend is in the way" do
      @friend = Pawn.create(position_x: 3, position_y: 5, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(1,7)).to eq true
    end
    it "returns true if moving northeast and friend is in the way" do
      @friend = Pawn.create(position_x: 5, position_y: 5, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(8,8)).to eq true
    end
    it "returns true if moving southwest and friend is in the way" do
      @friend = Pawn.create(position_x: 3, position_y: 3, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(1,1)).to eq true
    end
    it "returns true if moving southeast and friend is in the way" do
      @friend = Pawn.create(position_x: 5, position_y: 3, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(7,1)).to eq true
    end 
  end
  # range test - blocked next to ending point
  describe "is_obstructed? returns true if a piece is next to finish" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns true if moving west and enemy is in the way" do
      @enemy = Pawn.create(position_x: 2, position_y: 4, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(1,4)).to eq true
    end
    it "returns true if moving east and enemy is in the way" do
      @enemy = Pawn.create(position_x: 7, position_y: 4, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(8,4)).to eq true
    end
    it "returns true if moving north and enemy is in the way" do
      @enemy = Pawn.create(position_x: 4, position_y: 7, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(4,8)).to eq true
    end
    it "returns true if moving south and enemy is in the way" do
      @enemy = Pawn.create(position_x: 4, position_y: 2, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(4,1)).to eq true
    end           
    it "returns true if moving northwest and enemy is in the way" do
      @enemy = Pawn.create(position_x: 2, position_y: 6, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(1,7)).to eq true
    end
    it "returns true if moving northeast and enemy is in the way" do
      @enemy = Pawn.create(position_x: 7, position_y: 7, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(8,8)).to eq true
    end
    it "returns true if moving southwest and enemy is in the way" do
      @enemy = Pawn.create(position_x: 2, position_y: 2, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(1,1)).to eq true
    end
    it "returns true if moving southeast and enemy is in the way" do
      @enemy = Pawn.create(position_x: 6, position_y: 2, game: @g, player: @g.black_player)
      expect(@q.is_obstructed?(7,1)).to eq true
    end     
  end
  describe "is_obstructed? returns false if a piece is beyond destination" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns false if moving west and piece is beyond destination" do
      @friend = Pawn.create(position_x: 1, position_y: 4, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(2,4)).to eq false
    end
    it "returns false if moving east and piece is beyond destination" do
      @friend = Pawn.create(position_x: 8, position_y: 4, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(7,4)).to eq false      
    end
    it "returns false if moving north and piece is beyond destination" do
      @friend = Pawn.create(position_x: 4, position_y: 8, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(4,7)).to eq false
    end
    it "returns false if moving south and piece is beyond destination" do
      @friend = Pawn.create(position_x: 4, position_y: 1, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(4,2)).to eq false
    end
    it "returns false if moving northwest and piece is beyond destination" do
      @friend = Pawn.create(position_x: 1, position_y: 7, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(2,6)).to eq false
    end    
    it "returns false if moving northeast and piece is beyond destination" do
      @friend = Pawn.create(position_x: 8, position_y: 8, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(7,7)).to eq false  
    end
    it "returns false if moving southwest and piece is beyond destination" do
      @friend = Pawn.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(2,2)).to eq false
    end
    it "returns false if moving southeast and piece is beyond destination" do
      @friend = Pawn.create(position_x: 7, position_y: 1, game: @g, player: @g.white_player)
      expect(@q.is_obstructed?(6,2)).to eq false
    end    
  end
  describe "is_obstructed? returns true if the destination is off the board" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns true if dest_x is not legal (low)" do
      expect(@q.is_obstructed?(0,1)).to eq true      
    end
    it "returns true if dest_x is not legal (high)" do
      expect(@q.is_obstructed?(9,1)).to eq true      
    end
    it "returns true if dest_y is not legal (low)" do
      expect(@q.is_obstructed?(4,0)).to eq true      
    end
    it "returns true if dest_y is not legal (high)" do
      expect(@q.is_obstructed?(4,9)).to eq true      
    end
  end
  it "is_obstructed? returns true if destination = starting point" do
    @g = FactoryGirl.create(:joined_game)
    @k = Knight.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    expect(@k.is_obstructed?(4,4)).to eq true
  end

  describe "resolve_check? returns true if checked player captures the attacking piece", :check_block => true do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @k = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns true if one threat and it is captured" do
      threat = Queen.create(position_x: 4, position_y: 8, game: @g, player: @g.black_player)
      hero = Rook.create(position_x: 1, position_y: 8, game: @g, player: @g.white_player)
      expect(hero.resolve_check?(4, 8)).to eq true
    end
    it "returns true if one threat and it is blocked from the king" do
      threat = Queen.create(position_x: 4, position_y: 8, game: @g, player: @g.black_player)
      hero = Rook.create(position_x: 1, position_y: 7, game: @g, player: @g.white_player)
      expect(hero.resolve_check?(4, 7)).to eq true
    end    
  end

  describe "resolve_check? returns false if checked player fails to capture or block the attacker", :check_block => true do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @k = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end
    it "returns false if there is one threat that isn't captured or blocked" do
      threat = Queen.create(position_x: 4, position_y: 8, game: @g, player: @g.black_player)
      hero = Rook.create(position_x: 1, position_y: 7, game: @g, player: @g.white_player)
      expect(hero.resolve_check?(2, 7)).to eq false
    end
    it "returns false if there are multiple threats and only one is resolved" do
      threat = Queen.create(position_x: 4, position_y: 8, game: @g, player: @g.black_player)
      threat2 = Rook.create(position_x: 4, position_y: 1, game: @g, player: @g.black_player)
      hero = Knight.create(position_x: 3, position_y: 3, game: @g, player: @g.white_player)
      expect(hero.resolve_check?(4, 1)).to eq false
    end    
  end
end
