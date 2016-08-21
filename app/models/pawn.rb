class Pawn < Piece

  def is_valid_move?(dest_x, dest_y)	
    return false if game.endangering_king?(self.player, self)   
 	  if is_valid_enpassant?(dest_x, dest_y) 
 	  	enpassant(dest_x, dest_y)
 	  	return true 
 	  end
  	return false if is_obstructed?(dest_x, dest_y)
  	# is_obstructed normally allows an enemy to be on destination but pawn is special 	
  	return false if game.is_occupied?(dest_x, dest_y) && is_vertical_move?(dest_x, dest_y)
  	if is_valid_capture?(dest_x, dest_y)
      if game.is_in_check?(player) && !resolve_check?(dest_x, dest_y)
  		  return false
      end
  		return true
  	end
  	if player_id == game.white_player_id # player white
	  	if move_count == 0
	  		if (dest_y - position_y == 2 || dest_y - position_y == 1) && is_vertical_move?(dest_x, dest_y)
		      if game.is_in_check?(player) && !resolve_check?(dest_x, dest_y)
		  		  return false
		      end
	  			return true
	  		end
	  	else
	  		if dest_y - position_y == 1 && is_vertical_move?(dest_x, dest_y)
		      if game.is_in_check?(player) && !resolve_check?(dest_x, dest_y)
		  		  return false
		      end
	  			return true 
	  		end
	  	end
	  elsif player_id == game.black_player_id # player black
	  	if move_count == 0
	  		if position_y - dest_y <= 2 && position_x == dest_x
		      if game.is_in_check?(player) && !resolve_check?(dest_x, dest_y)
		  		  return false
		      end  			  				  			
          return true 
	  		end
	  	else
	  		if position_y - dest_y == 1 && position_x == dest_x
		      if game.is_in_check?(player) && !resolve_check?(dest_x, dest_y)
		  		  return false
		      end  			  				  			
          return true 
	  		end
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
		#logger.info ("en passant #{dest_x}, #{dest_y}")
		if player_id == game.white_player_id
			enemy = game.black_player_id
			return false if position_y > 5
		else
			enemy = game.white_player_id
			return false if position_y < 4
		end 
    #logger.info("assessing target pawn next at #{dest_x}, #{position_y}, player: #{enemy}")
		target_pawn = game.pieces.where(type: "Pawn", player: enemy, position_x: dest_x, position_y: position_y).first
    #logger.info("target pawn: #{target_pawn.inspect}")
    #logger.info("game last moved piece: #{game.last_moved_piece.inspect}")
		return false if !target_pawn
		return false if target_pawn != game.last_moved_piece
		return false if target_pawn.move_count > 1
    #logger.info("assessing destination: #{target_pawn.position_x}, #{target_pawn.position_y}")
		if player_id == game.white_player_id
			return false if dest_y != 6
			return false if target_pawn.position_x != dest_x
			return false if game.is_in_check?(player) && !resolve_check?(dest_x, 5)
		else
			return false if dest_y != 3
			return false if target_pawn.position_x != dest_x
			return false if game.is_in_check?(player) && !resolve_check?(dest_x, 4)
		end
		
		true
	end 

  def enpassant(dest_x, dest_y)
    player_id == game.white_player_id ? enemy = game.black_player_id : enemy = game.white_player_id
    target_pawn = game.pieces.where(type: "Pawn", player: enemy, position_x: dest_x, position_y: position_y).first
    target_pawn.update_attributes(position_x: nil, position_y: nil, is_active: false)
  end
end
