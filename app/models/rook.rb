class Rook < Piece
	def is_valid_move?(dest_x, dest_y)
		return false if is_obstructed?(dest_x, dest_y) 
  	if is_vertical_move?(dest_x, dest_y) || is_horizontal_move?(dest_x, dest_y)
      if game.is_in_check?(player) && !resolve_check?(dest_x, dest_y)
        return false
      end
      if game.endangering_king?(self.player, self)
  		  return false
      end
      return true 
  	end  	
  	false
  end
end
