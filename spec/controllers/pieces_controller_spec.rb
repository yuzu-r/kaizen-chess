require 'rails_helper'

RSpec.describe PiecesController, type: :controller do

  describe "pieces#move action" do
    before :each do
      @g = FactoryGirl.create(:joined_game)
      @q = Queen.create(position_x: 4, position_y: 4, game: @g, player: @g.white_player)
    end

    it "should successfully change a piece's location if the destination is valid" do
      patch :move, { id: @q.id, game_id: @g.id, position_x: 6, position_y: 6, format: :json}
      expect(response).to redirect_to game_path(@g)
      @q.reload
      expect(@q.move_count).to eq 1
      expect(@q.is_selected).to eq false
      expect(@q.position_x).to eq 6
      expect(@q.position_y).to eq 6 
    end

    it "should not change a piece's location if the destination is invalid" do
      patch :move, { id: @q.id, game_id: @g.id, position_x: 5, position_y: 6, format: :json}
      expect(flash[:alert]).to eq "Invalid Move"
      expect(response).to redirect_to game_path(@g)
      @q.reload
      expect(@q.move_count).to eq 0
      expect(@q.position_x).to eq 4
      expect(@q.position_y).to eq 4 
    end
  end

end
