class Pawn < Piece
	# TODO: en passant and adding diagonal movement for capturing
  def is_valid_move?(dest_x, dest_y)	
  	return false if is_obstructed?(dest_x, dest_y)	
  	if player_id == game.white_player_id # player white
	  	if move_count == 0
	  		return true if (dest_y - position_y == 2 || dest_y - position_y == 1) && is_vertical_move?(dest_x, dest_y)
	  	else
	  		return true if dest_y - position_y == 1 && is_vertical_move?(dest_x, dest_y)
	  	end
	  elsif player_id == game.black_player_id # player black
	  	if move_count == 0
	  		return true if position_y - dest_y <= 2 && position_x == dest_x
	  	else
	  		return true if position_y - dest_y == 1 && position_x == dest_x
	  	end
	  end
	  false
	end
end
