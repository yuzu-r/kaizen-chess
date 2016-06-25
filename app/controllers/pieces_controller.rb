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
    puts 'param pos x ==' 
    position_x = params[:position_x].to_i
    position_y = params[:position_y].to_i
    if @piece.is_valid_move?(position_x, position_y)
      @piece.capture(position_x, position_y)
      @move_count = @piece.move_count + 1
      @piece.update_attributes(position_x: position_x, position_y: position_y, move_count: @move_count, is_selected: false)

      render :json => { :success => "success", :status_code => "200" }

    else
      render :status => 400
    end
    
  end

end
