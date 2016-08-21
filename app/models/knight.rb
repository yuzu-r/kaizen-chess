class Knight < Piece
	def is_valid_move?(dest_x, dest_y)
		return false if is_obstructed?(dest_x, dest_y)
    return false if game.endangering_king?(self.player, self)
		if is_knight_move?(dest_x, dest_y)
      if game.is_in_check?(player) && !resolve_check?(dest_x, dest_y)
        return false
      end
			return true 
		end
		false
	end
end
