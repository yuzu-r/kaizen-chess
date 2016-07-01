class PiecesController < ApplicationController
  def move
    @piece = Piece.find(params[:id])
    @game = Game.find(params[:game_id])
    position_x = params[:position_x].to_i
    position_y = params[:position_y].to_i
    
    if @piece.is_valid_move?(position_x, position_y)
      @piece.capture(position_x, position_y)
      @move_count = @piece.move_count + 1

      @piece.update_attributes(position_x: position_x, position_y: position_y, move_count: @move_count)

      if @piece.player == @game.white_player
        @game.update_attributes(active_player: @game.black_player)
      else
        @game.update_attributes(active_player: @game.white_player)
      end

      render :json => { :success => "success", :status_code => "200" }
    else
      render :json => { :errors => "Move not allowed!" }, :status => 200
    end
    
  end

end
