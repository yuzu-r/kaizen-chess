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

      if @piece.type == 'Pawn' && position_y == 8 || position_y == 1
        # this is a pawn promotion
        # do not update the active player yet
      else
        if @piece.player == @game.white_player
          @game.update_attributes(active_player: @game.black_player)
          @game.update_active_player_firebase(@game.black_player)
        else
          @game.update_attributes(active_player: @game.white_player)
          @game.update_active_player_firebase(@game.white_player)
        end
      end
      @game.update_attributes(last_moved_piece: @piece)
      render :json => { :success => "success", :status_code => "200" }
    else
      render :json => { :errors => "Move not allowed!" }, :status => 200
    end
    
  end

  def promote
    @piece = Piece.find(params[:id])
    @game = Game.find(params[:game_id])
    
    @piece.update_attributes(type: params[:type])
    if @piece.player == @game.white_player
      @game.update_attributes(active_player: @game.black_player)
      @game.update_active_player_firebase(@game.black_player)
    else
      @game.update_attributes(active_player: @game.white_player)
      @game.update_active_player_firebase(@game.white_player)
    end

    render :json => { :success => "success", :status_code => "200" }
  end

end
