class Piece < ActiveRecord::Base
  belongs_to :player, class_name: "User"
  belongs_to :game

  # override stripping of 'type' field from json
  def as_json(options={})
    super(options.merge({:methods => :type}))
  end

  # Checks to see if spaces horizontally, vertically, or diagonally are blocking 
  # movement between a piece's current location & dest_x/dest_y
  def is_obstructed?(dest_x, dest_y) 

    # Checks to see if destination is outside board bounds
    return true if dest_x < 1 || dest_x > 8 || dest_y < 1 || dest_y > 8 

    # Checks to see if destination is occupied by a friend
    return true if self.game.is_occupied?(dest_x, dest_y) && self.player == self.game.pieces.where(position_x:dest_x, position_y: dest_y).first.player

    return false if self.type == "Knight"

    if self.position_y == dest_y # Horizontal movement
      if self.position_x < dest_x # East
        (position_x + 1).upto(dest_x - 1) do |x|
          return true if self.game.is_occupied?(x, dest_y)
        end 
      else # West
        (position_x - 1).downto(dest_x + 1) do |x|
          return true if self.game.is_occupied?(x, dest_y)
        end 
      end 
    elsif self.position_x == dest_x # Vertical movement
      if self.position_y < dest_y # North
        (position_y + 1).upto(dest_y - 1) do |y|
          return true if self.game.is_occupied?(dest_x, y)
        end 
      else # South
        (position_y - 1).downto(dest_y + 1) do |y|
          return true if self.game.is_occupied?(dest_x, y)
        end 
      end 
    elsif #Diagonal movement
      if self.position_x < dest_x && self.position_y < dest_y # Northeast
        (position_x + 1).upto(dest_x - 1) do |x|
          (position_y + 1).upto(dest_y - 1) do |y|
            return true if self.game.is_occupied?(x, y) && (x - position_x).abs == (y - position_y).abs
          end 
        end 
      elsif self.position_x > dest_x && self.position_y < dest_y # Northwest
        (position_x - 1).downto(dest_x + 1) do |x|
          (position_y + 1).upto(dest_y - 1) do |y|
            return true if self.game.is_occupied?(x, y) && (x - position_x).abs == (y - position_y).abs
          end 
        end 
      elsif self.position_x < dest_x && self.position_y > dest_y # Southeast
        (position_x + 1).upto(dest_x - 1) do |x|
          (position_y - 1).downto(dest_y + 1) do |y|
            return true if self.game.is_occupied?(x, y) && (x - position_x).abs == (y - position_y).abs
          end 
        end 
      elsif self.position_x > dest_x && self.position_y > dest_y # Southwest
        (position_x - 1).downto(dest_x + 1) do |x|
          (position_y - 1).downto(dest_y + 1) do |y|
            return true if self.game.is_occupied?(x, y) && (x - position_x).abs == (y - position_y).abs
          end 
        end
      end   
    end 
    false
  end 

  def is_diagonal_move?(dest_x, dest_y)
  	if (self.position_y - dest_y).abs == (self.position_x - dest_x).abs
  		return true
  	end
  	false
	end

	def is_vertical_move?(dest_x, dest_y)
		if self.position_x == dest_x && self.position_y != dest_y
			return true
		end
		false
	end

	def is_horizontal_move?(dest_x, dest_y)
		if self.position_y == dest_y && self.position_x != dest_x
			return true
		end
		false
	end

	def is_knight_move?(dest_x, dest_y)
		if ( (self.position_x - dest_x).abs == 1 && (self.position_y - dest_y).abs == 2 ) || ( (self.position_x - dest_x).abs == 2 && (self.position_y - dest_y).abs == 1 )
			 	return true
		end
		false		
	end

  def is_valid_capture?(dest_x, dest_y)
    # returns true if the destination contains an enemy
    # move is validated elsewhere (is_valid_move)
    # pawn overrides this since it moves differently when capturing
    target_piece = self.game.pieces.where(position_x: dest_x, position_y: dest_y).first
    (!target_piece || target_piece.player == self.player) ? false : true
  end

  def capture(dest_x, dest_y)
    # check if valid
    # set the enemy piece to nil and off the board
    # moving to the now empty spot, incrementing move_count, updating game.active_player is left to the move method
    # return true on success, false on fail 
    if self.is_valid_capture?(dest_x,dest_y)
      target_piece = self.game.pieces.where(position_x: dest_x, position_y: dest_y).first
      target_piece.update_attributes(position_x: nil, position_y: nil, is_active: false)
      return true
    end
    return false
  end

  def resolve_check?(dest_x, dest_y)
    # if player is in check, does moving a piece to dest_x, dest_y get the player out of check?
    # if this is false, the move is not valid. this is called by each piece's is valid move method
    # note - this method is piece type agnostic, it does not care how the piece gets there
    # first find the threatening piece or pieces on the board
    # there is stuff going on here. why is active record querying other games? add some "self"
    # or this might need to move into the game model anyway.
    logger.info "IN RESOLVE CHECK"
    if player == game.white_player
      king = game.pieces.where(type: "King", player: player).first
      king_x = king.position_x
      king_y = king.position_y
      threatening_piece = nil
      threats=[]
      threat_counter = 0
      game.black_player.pieces.where(is_active: true).each do |piece|
        if piece.type != "King"
          if piece.is_valid_move?(king_x, king_y)
            threats[threat_counter] = piece
            threat_counter += 1
          end
        end
      end
      logger.info "threats to white: #{threat_counter}"
      # for each threatening piece, does bishop block or capture it?
      return true if threats.empty?
      threats.each do |p|
        isCapture = dest_x == p.position_x && dest_y == p.position_y
        return false if !isCapture && !game.valid_check_defense?(p, dest_x, dest_y, king)
      end
      return true
    else 
      king = game.pieces.where(type: "King", player: player).first
      king_x = king.position_x
      king_y = king.position_y
      threatening_piece = nil
      threats = []
      threat_counter = 0
      game.white_player.pieces.where(is_active: true).each do |piece|
        if piece.type != "King"
          if piece.is_valid_move?(king_x, king_y)
            threats[threat_counter] = piece
            threat_counter += 1
          else
          end
        end
      end
      logger.info "threats to black: #{threat_counter}"
      # for each threatening piece, does bishop block or capture it?
      return true if threats.empty?
      threats.each do |p|
        isCapture = dest_x == p.position_x && dest_y == p.position_y
        return false if !isCapture && !game.valid_check_defense?(p, dest_x, dest_y, king)
      end
      return true   
    end
  end

end

