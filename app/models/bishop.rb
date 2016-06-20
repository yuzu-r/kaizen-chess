class Bishop < Piece
	def is_valid_move?(dest_x, dest_y)
  	return false if is_obstructed?(dest_x, dest_y) 
  	if is_diagonal_move?(dest_x, dest_y)
  		return true
  	end
  	false
  end
end
