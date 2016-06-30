require 'rails_helper'

RSpec.describe PiecesController, type: :controller do

  describe "pieces#move action" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end

    it "should successfully change a piece's location if the destination is valid" do
      patch :move, { id: @q.id, game_id: @g.id, position_x: 6, position_y: 6, format: :json}
      #expect(response).to redirect_to game_path(@g)
      @q.reload
      expect(@q.move_count).to eq 1
      expect(@q.position_x).to eq 6
      expect(@q.position_y).to eq 6 
    end

    it "should move both king & rook if is_valid_castle?" do
      @k = King.create(position_x: 5, position_y: 1, game: @g, player: @g.white_player)
      @r = Rook.create(position_x: 1, position_y: 1, game: @g, player: @g.white_player)
      patch :move, { id: @k.id, game_id: @g.id, position_x: 3, position_y: 1, format: :json}
      @k.reload
      @r.reload
      expect(@k.move_count).to eq 1
      expect(@k.position_x).to eq 3
      expect(@k.position_y).to eq 1 
      
      expect(@r.move_count).to eq 1
      expect(@r.position_x).to eq 4
      expect(@r.position_y).to eq 1 
    end

    it "should not change a piece's location if the destination is invalid" do
      patch :move, { id: @q.id, game_id: @g.id, position_x: 5, position_y: 6, format: :json}
      #expect(flash[:alert]).to eq "Invalid Move"
      #expect(response).to redirect_to game_path(@g)
      @q.reload
      expect(@q.move_count).to eq 0
      expect(@q.position_x).to eq 4
      expect(@q.position_y).to eq 4 
    end

    it "should change the active player to black if white moves" do
      patch :move, { id: @q.id, game_id: @g.id, position_x: 6, position_y: 6, format: :json}
      @g.reload
      expect(@g.active_player).to eq @g.black_player
    end

    it "non-pawn should capture a piece if moving to an enemy location" do
      p = Pawn.create(position_x: 4, position_y: 7, game: @g, player: @g.black_player)
      patch :move, { id: @q.id, game_id: @g.id, position_x: 4, position_y: 7, format: :json}
      @q.reload
      p.reload
      expect(@q.move_count).to eq 1
      expect(p.is_active).to eq false
    end

    it "pawn should capture a piece if moving to an enemy location diagonally" do
      p = Pawn.create(position_x: 3, position_y: 5, game: @g, player: @g.black_player)
      patch :move, { id: p.id, game_id: @g.id, position_x: 4, position_y: 4, format: :json}
      @q.reload
      p.reload
      expect(p.move_count).to eq 1
      expect(@q.is_active).to eq false
    end

    it "allows a pawn to move forward to an empty space" do
      p = Pawn.create(position_x: 3, position_y: 5, game: @g, player: @g.black_player)
      patch :move, { id: p.id, game_id: @g.id, position_x: 3, position_y: 4, format: :json}
      p.reload
      expect(p.move_count).to eq 1
    end

    it "prevents a pawn from moving diagonally to an empty space" do
      p = Pawn.create(position_x: 3, position_y: 5, game: @g, player: @g.black_player)
      patch :move, { id: p.id, game_id: @g.id, position_x: 2, position_y: 4, format: :json}
      p.reload
      expect(p.move_count).to eq 0     
    end

    it "prevents a pawn from moving forward when an enemy is in the way" do
      p = Pawn.create(position_x: 4, position_y: 5, game: @g, player: @g.black_player)
      patch :move, { id: p.id, game_id: @g.id, position_x: 4, position_y: 4, format: :json}
      p.reload
      @q.reload
      expect(@q.is_active).to eq true
      expect(p.move_count).to eq 0 
    end
  end
end
