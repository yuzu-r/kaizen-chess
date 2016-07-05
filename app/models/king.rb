class King < Piece
	def is_valid_move?(dest_x, dest_y)
    return false if will_be_in_check?(dest_x, dest_y)
		return false if is_obstructed?(dest_x, dest_y) 
		if moves_only_one_space?(dest_x, dest_y)
			return true
		end
		if is_valid_castle?(dest_x, dest_y)
      castle(dest_x, dest_y)
  		return true
  	end
		false
	end

	def moves_only_one_space?(dest_x, dest_y)
		return false if position_x == dest_x && position_y == dest_y
		if (position_x - dest_x).abs <= 1 && (position_y - dest_y).abs <= 1 
			return true
		end 
		false
	end

	def get_rook(position_x)	
		Rook.where("player_id =? AND game_id = ? AND position_x=?", player_id, game_id, position_x).first
	end

  
  def will_be_in_check?(dest_x, dest_y) 
  # If a king moves to dest_x & dest_y, this method will see if that puts the King in check.
    if player == game.white_player
      game.black_player.pieces.where(game: game, is_active: true).each do |piece|
        if piece.type == "Pawn"
          return true if (dest_x - piece.position_x).abs == 1 && piece.position_y - dest_y == 1
        elsif piece.type == "King"
          return true if piece.moves_only_one_space?(dest_x, dest_y)
        else
          return true if piece.is_valid_move?(dest_x, dest_y)
        end
      end
    else
      game.white_player.pieces.where(game: game, is_active: true).each do |piece|
        if piece.type == "Pawn"
          return true if (dest_x - piece.position_x).abs == 1 && dest_y - piece.position_y == 1
        elsif piece.type == "King"
          return true if piece.moves_only_one_space?(dest_x, dest_y)
        else
          return true if piece.is_valid_move?(dest_x, dest_y)
        end
      end
    end
    return false
  end 

  def is_valid_castle?(dest_x, dest_y)
    return false if game.is_in_check?(player)
    return false if will_be_in_check?(dest_x, dest_y) 
  	return false if move_count > 0
  	return false if ![3,7].include?(dest_x)
  	return false if !is_horizontal_move?(dest_x, dest_y)

  	if dest_x > position_x
  		rook = get_rook(8)
  	else
  		rook = get_rook(1)
  	end

  	return false if !rook
  	return false if rook.move_count > 0
  	
  	# loop through each position between king rook
  	x_delta = position_x - rook.position_x
  	if x_delta > 0
  		for x in rook.position_x+1..position_x-1 
  			if game.is_occupied?(x, position_y)
  				return false
  			end
        if will_be_in_check?(x, position_y)
         return false
        end
  		end
  	elsif x_delta < 0
  		for x in position_x+1..rook.position_x-1 
  			if game.is_occupied?(x, position_y)
  				return false
  			end
        if will_be_in_check?(x, position_y)
          return false
        end
  		end
  	end
  	true
  end

  def castle(dest_x, dest_y)
    if dest_x > position_x
      rook = get_rook(8)
      move_count = rook.move_count
      rook.update_attributes(position_x: 6, move_count: move_count + 1)
    else
      rook = get_rook(1)
      move_count = rook.move_count
      rook.update_attributes(position_x: 4, move_count: move_count + 1)
    end
  end

end
