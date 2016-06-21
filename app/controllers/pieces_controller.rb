class PiecesController < ApplicationController
  def select
    # toggles is_selected for the piece in question (select/de-select)
    # if a piece is selected, any previously selected piece is de-selected
    # note: this does NOT currently check whose turn it is!
    # add validation to make sure the piece selected belongs to player whose turn it is 
    @piece = Piece.find(params[:id])
    @game = Game.find(params[:game_id])
    if @piece.is_selected
      @piece.update_attributes(is_selected: false)
    else
      @game.pieces.each do |p|
        p.update_attributes(is_selected: false) if p.is_selected
      end
      @piece.update_attributes(is_selected: true)
    end
    redirect_to game_path(@game)

  end

  def move
    @piece = Piece.find(params[:id])
    @game = Game.find(params[:game_id])
    if @piece.is_valid_move?(params[:position_x], params[:position_y])
      @piece.capture(params[:position_x], params[:position_y])
      @move_count = @piece.move_count + 1
      @piece.update_attributes(position_x: params[:position_x], position_y: params[:position_y], move_count: @move_count, is_selected: false)
    else
      flash[:alert] = "Invalid Move"
    end
    redirect_to game_path(@game)
  end

end
