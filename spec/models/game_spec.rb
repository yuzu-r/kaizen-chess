require 'rails_helper'

RSpec.describe Game, type: :model do
  it "can be created without a black player" do
    game_count = Game.count
    expect(FactoryGirl.create(:game)).to be_valid
    expect(Game.count).to eq game_count+1
  end

  it "has a valid factory with both players set" do
    game_count = Game.count
    g=FactoryGirl.create(:joined_game)
    expect(g).to be_valid
    expect(Game.count).to eq game_count+1
    expect(g.black_player).to_not be nil
  end

  context "active_player validation" do
    it "allows active_player to be white player" do
      g=FactoryGirl.create(:joined_game)
      g.active_player_id = g.white_player_id
      expect(g).to be_valid
      expect(g.active_player_id).to eq g.white_player_id
    end

    it "allows active_player to be black player" do
      g=FactoryGirl.create(:joined_game)
      g.active_player_id = g.black_player_id
      expect(g).to be_valid
      expect(g.active_player_id).to eq g.black_player_id
    end

    it "does not allow active_player to be some third player" do
      g=FactoryGirl.create(:joined_game)
      u= FactoryGirl.create(:user)
      g.active_player_id = u.id
      expect(g).to_not be_valid
    end
  end

  describe "is_in_check? returns true if player is in check" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
    end   
    it "is true if white player is in check by pawn" do
      white_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
      black_pawn = Pawn.create(position_x: 3, position_y: 5, game: @g, player: @g.black_player)
      expect(@g.is_in_check?(@g.white_player)).to eq true
    end
    it "is true if black player is in check by rook" do
      black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      white_rook = Rook.create(position_x: 1, position_y: 4, game: @g, player: @g.white_player)
      expect(@g.is_in_check?(@g.black_player)).to eq true
    end
    it "is true if black player is in check by knight" do
      black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      white_knight = Knight.create(position_x: 6, position_y: 5, game: @g, player: @g.white_player)
      expect(@g.is_in_check?(@g.black_player)).to eq true
    end
    it "is true if king is surrounded by own pieces and enemy knight can capture", :bug => true do
      white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      white_queen = Queen.create(position_x: 4, position_y: 1, game: @g, player: @g.white_player)
      white_bishop = Bishop.create(position_x: 6, position_y: 1, game: @g, player: @g.white_player)
      white_pawn1 = Pawn.create(position_x: 5, position_y: 2, game: @g, player: @g.white_player)
      white_pawn2 = Pawn.create(position_x: 6, position_y: 2, game: @g, player: @g.white_player)
      white_pawn3 = Pawn.create(position_x: 7, position_y: 2, game: @g, player: @g.white_player)
      black_knight = Knight.create(position_x: 6, position_y: 3, game: @g, player: @g.black_player)
      expect(@g.is_in_check?(@g.white_player)).to eq true
    end

  end

  describe "is_in_check? false if player is not in check" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
    end   
    it "is false if white player can't capture black king (obstructed)" do
      black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      white_queen = Queen.create(position_x: 1, position_y: 4, game: @g, player: @g.white_player)
      black_pawn = Pawn.create(position_x: 3, position_y: 4, game: @g, player: @g.black_player)
      expect(@g.is_in_check?(@g.black_player)).to eq false
    end

    it "is false if black player can't capture white king (no pieces in range)" do
      white_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
      black_bishop = Bishop.create(position_x: 3, position_y: 4, game: @g, player: @g.black_player)
      black_pawn = Pawn.create(position_x: nil, position_y: nil, is_active: false, game: @g, player: @g.black_player)
      black_pawn2 = Pawn.create(position_x: 4, position_y: 5, game: @g, player: @g.black_player)
      black_king = King.create(position_x: 1, position_y: 1, game: @g, player: @g.black_player)
      expect(@g.is_in_check?(@g.black_player)).to eq false
    end

  end

  describe "is_in_checkmate?" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
    end 
    it "is true if white player is in checkmate" do
      @white_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
      @black_rook1 = Rook.create(position_x: 1, position_y: 5, game: @g, player: @g.black_player)
      @black_rook2 = Rook.create(position_x: 1, position_y: 3, game: @g, player: @g.black_player)
      @black_rook3 = Rook.create(position_x: 3, position_y: 8, game: @g, player: @g.black_player)
      @black_rook4 = Rook.create(position_x: 5, position_y: 8, game: @g, player: @g.black_player)
      @threatening_black_rook = Rook.create(position_x: 4, position_y: 8, game: @g, player: @g.black_player)
      expect(@g.is_in_checkmate?(@g.white_player)).to eq true
    end
    it "is true if black player is in checkmate" do
      black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      @white_rook1 = Rook.create(position_x: 1, position_y: 5, game: @g, player: @g.white_player)
      @white_rook2 = Rook.create(position_x: 1, position_y: 3, game: @g, player: @g.white_player)
      @white_rook3 = Rook.create(position_x: 3, position_y: 8, game: @g, player: @g.white_player)
      @white_rook4 = Rook.create(position_x: 5, position_y: 8, game: @g, player: @g.white_player)
      @threatening_white_rook = Rook.create(position_x: 4, position_y: 8, game: @g, player: @g.white_player)
      expect(@g.is_in_checkmate?(@g.black_player)).to eq true
    end
    it "is false if white player is not in check" do
      @white_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
      expect(@g.is_in_checkmate?(@g.white_player)).to eq false
    end
    it "is false if black player is not in check" do
      @black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      expect(@g.is_in_checkmate?(@g.black_player)).to eq false
    end
  end

  describe "is_in_checkmate? is false if black king can escape" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @pawn1 = Pawn.create(position_x: 6, position_y: 5, game: @g, player: @g.white_player)
      @pawn2 = Pawn.create(position_x: 6, position_y: 6, game: @g, player: @g.white_player)
      @pawn3 = Pawn.create(position_x: 5, position_y: 6, game: @g, player: @g.white_player)
      @pawn4 = Pawn.create(position_x: 2, position_y: 6, game: @g, player: @g.white_player)
      @pawn5 = Pawn.create(position_x: 2, position_y: 5, game: @g, player: @g.white_player)
      @pawn6 = Pawn.create(position_x: 2, position_y: 4, game: @g, player: @g.white_player)
      @pawn7 = Pawn.create(position_x: 5, position_y: 4, game: @g, player: @g.white_player)
      @pawn8 = Pawn.create(position_x: 6, position_y: 4, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
      @threatening_white_rook = Rook.create(position_x: 4, position_y: 8, game: @g, player: @g.white_player)
    end 

    after :each do
      expect(@g.is_in_check?(@g.black_player)).to eq true 
      expect(@black_king.can_escape_from_check?).to eq true
      expect(@g.is_in_checkmate?(@g.black_player)).to eq false
    end  

    it "to the Northeast" do
      @pawn2.destroy

    end 

    it "to the North" do
      @pawn3.destroy
      @threatening_white_rook.update_attributes(position_x: 3, position_y: 4)
    end

    it "to the Northwest" do
      @pawn4.destroy
    end

    it "to the West" do
      @pawn5.destroy
    end 

    it "to the Southwest" do
      @pawn6.destroy
    end 

    it "to the South" do
      @pawn7.destroy
    end 

    it "to the Southeast" do
      @pawn8.destroy
    end 

    it "to the East" do
      @pawn1.destroy
    end 
  end

   describe "is_in_checkmate? is false if black can block a check" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @pawn1 = Pawn.create(position_x: 6, position_y: 5, game: @g, player: @g.white_player)
      @pawn2 = Pawn.create(position_x: 6, position_y: 6, game: @g, player: @g.white_player)
      @pawn3 = Pawn.create(position_x: 5, position_y: 6, game: @g, player: @g.white_player)
      @pawn4 = Pawn.create(position_x: 2, position_y: 6, game: @g, player: @g.white_player)
      @pawn5 = Pawn.create(position_x: 2, position_y: 5, game: @g, player: @g.white_player)
      @pawn6 = Pawn.create(position_x: 2, position_y: 4, game: @g, player: @g.white_player)
      @pawn7 = Pawn.create(position_x: 5, position_y: 4, game: @g, player: @g.white_player)
      @pawn8 = Pawn.create(position_x: 6, position_y: 4, game: @g, player: @g.white_player)
      @black_king = King.create(position_x: 4, position_y: 4, game: @g, player: @g.black_player)
    end 

    after :each do
      expect(@g.is_in_check?(@g.black_player)).to eq true 
      expect(@black_king.can_escape_from_check?).to eq false
      expect(@g.is_in_checkmate?(@g.black_player)).to eq false
    end 

    it "to the Northeast" do
      @threatening_white_piece = @pawn2.update_attributes(type:"Queen")
      @blocker = Rook.create(position_x: 3, position_y: 5, game: @g, player: @g.black_player)
    end 

    it "to the North" do
      @threatening_white_piece = Rook.create(position_x: 4, position_y: 8, game: @g, player: @g.white_player)
      @blocker = Rook.create(position_x: 3, position_y: 5, game: @g, player: @g.black_player)
    end

    it "to the Northwest" do
      @threatening_white_piece = @pawn4.update_attributes(type:"Queen")
      @blocker = Rook.create(position_x: 3, position_y: 1, game: @g, player: @g.black_player)
    end

    it "to the West" do
      @threatening_white_piece = @pawn6.update_attributes(type:"Queen")
      @blocker = Rook.create(position_x: 3, position_y: 1, game: @g, player: @g.black_player)
    end 

    it "to the Southwest" do
      @threatening_white_piece = Queen.create(position_x: 2, position_y: 2, game: @g, player: @g.white_player)
      @blocker = Rook.create(position_x: 3, position_y: 5, game: @g, player: @g.black_player)
    end 

    it "to the South" do
      @threatening_white_piece = Rook.create(position_x: 4, position_y: 1, game: @g, player: @g.white_player)
      @blocker = Rook.create(position_x: 1, position_y: 3, game: @g, player: @g.black_player)
    end 

    it "to the Southeast" do
      @threatening_white_piece = Queen.create(position_x: 7, position_y: 1, game: @g, player: @g.white_player)
      @blocker = Rook.create(position_x: 1, position_y: 3, game: @g, player: @g.black_player)
    end 

    it "to the East" do
      @pawn7.destroy
      @pawn9 = Pawn.create(position_x: 3, position_y: 4, game: @g, player: @g.white_player)
      @threatening_white_piece = @pawn8.update_attributes(type:"Queen")
      @blocker = Rook.create(position_x: 5, position_y: 1, game: @g, player: @g.black_player)
    end 
 
  end

  describe "checkmate when king can be defended by capture" do
    it "is_in_checkmate? returns false if player can capture the threatening piece", :bug => true do
      @g = FactoryGirl.create(:joined_game)
      white_king = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      white_queen = Queen.create(position_x: 4, position_y: 1, game: @g, player: @g.white_player)
      white_bishop = Bishop.create(position_x: 6, position_y: 1, game: @g, player: @g.white_player)
      white_pawn1 = Pawn.create(position_x: 5, position_y: 2, game: @g, player: @g.white_player)
      white_pawn2 = Pawn.create(position_x: 6, position_y: 2, game: @g, player: @g.white_player)
      white_pawn3 = Pawn.create(position_x: 7, position_y: 2, game: @g, player: @g.white_player)
      black_knight = Knight.create(position_x: 6, position_y: 3, game: @g, player: @g.black_player)
      expect(@g.is_in_checkmate?(@g.white_player)).to eq false
    end
  end

end
