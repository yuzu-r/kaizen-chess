class Bishop < Piece
	def is_valid_move?(dest_x, dest_y)
  	return false if is_obstructed?(dest_x, dest_y) 
  	if is_diagonal_move?(dest_x, dest_y)
      if game.is_in_check?(player) && resolve_check?(dest_x, dest_y)
  		  return true
      end
  	end
  	false
  end

  def resolve_check?(dest_x, dest_y)
    # if the bishop's player is in check, does moving the bishop resolve it?
    # if it does not, the move is not valid
    # find the threatening piece or pieces(?) on the board
    if player == game.white_player
      king = game.pieces.where(type: "King", player: white_player).first
      king_x = king.position_x
      king_y = king.position_y
      threatening_piece = nil
      threats=[]
      threat_counter = 0
      game.black_player.pieces.where(is_active: true).each do |piece|
        if piece.type != "King"
          threatening_piece = piece if piece.is_valid_move?(king_x, king_y)
          threats[threat_counter] = piece
          threat_counter += 1
        end
      end
      # for each threatening piece, does bishop block or capture it?
      # capture: check if destination is the location of the threatening piece
      # block: valid_check_defense?(threatening_piece, block_x, block_y, king)


    else 
      king = game.pieces.where(type: "King", player: black_player).first
      king_x = king.position_x
      king_y = king.position_y
      threatening_piece = nil
      game.white_player.pieces.where(is_active: true).each do |piece|
        if piece.type != "King"
          threatening_piece = piece if piece.is_valid_move?(king_x, king_y)
          threats[threat_counter] = piece
          threat_counter += 1         
        end
      end
    end

  end
end
