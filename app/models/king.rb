class King < Piece
	def is_valid_move?(dest_x, dest_y)
		return false if is_obstructed?(dest_x, dest_y) 
		if (position_x - dest_x).abs <= 1 && (position_y - dest_y).abs <= 1
			return true
		end
		false
	end
end
