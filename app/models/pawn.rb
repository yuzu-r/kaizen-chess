class Pawn < Piece

  def is_valid_move?(dest_x, dest_y)	
 	  if is_valid_enpassant?(dest_x, dest_y)
 	  	enpassant(dest_x, dest_y)
 	  	return true 
 	  end
  	return false if is_obstructed?(dest_x, dest_y)
  	# is_obstructed normally allows an enemy to be on destination but pawn is special 	
  	return false if game.is_occupied?(dest_x, dest_y) && is_vertical_move?(dest_x, dest_y)
  	return true if is_valid_capture?(dest_x, dest_y)	
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

  def is_valid_capture?(dest_x, dest_y)
	  # returns true if the destination contains an enemy
	  # pawns have to check for diagonal
	  return false if is_obstructed?(dest_x, dest_y)
	  # white pawn
		if self.player_id == self.game.white_player_id 
			if (position_x - dest_x).abs == 1 && (dest_y - position_y) == 1
				target_piece = self.game.pieces.where(position_x: dest_x, position_y: dest_y).first
	  		return true if (target_piece && target_piece.player != self.player) 
			end
		else
			if (position_x - dest_x).abs == 1 && (position_y - dest_y) == 1
				target_piece = self.game.pieces.where(position_x: dest_x, position_y: dest_y).first
	  		return true if (target_piece && target_piece.player != self.player) 
	  	end
		end
		return false
	end

	def is_valid_enpassant?(dest_x, dest_y)

		if player_id == game.white_player_id
			enemy = game.black_player_id
			return false if position_y > 5
		else
			enemy = game.white_player_id
			return false if position_y < 4
		end 

		target_pawn = game.pieces.where(type: "Pawn", player: enemy, position_x: dest_x, position_y: position_y).first
		return false if !target_pawn
		return false if target_pawn != game.last_moved_piece
		return false if target_pawn.move_count > 1


		if player_id == game.white_player_id
			return false if dest_y != 6
			return false if target_pawn.position_x != dest_x
		else
			return false if dest_y != 3
			return false if target_pawn.position_x != dest_x
		end
		
		true
	end 

  def enpassant(dest_x, dest_y)
    player_id == game.white_player_id ? enemy = game.black_player_id : enemy = game.white_player_id
    target_pawn = game.pieces.where(type: "Pawn", player: enemy, position_x: dest_x, position_y: position_y).first
    target_pawn.update_attributes(position_x: nil, position_y: nil, is_active: false)
  end

end
