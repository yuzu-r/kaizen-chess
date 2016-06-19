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

  def is_valid_move?(dest_x, dest_y)
  	
  	return false if is_obstructed?(dest_x, dest_y) 

  	# if check move is not valid!

  	# pawn # need to accout for backwards and which team
  	
  	if self.type == 'Pawn'
	  	if self.player_id == self.game.white_player_id # player white
		  	if self.move_count == 0
		  		return true if (dest_y - self.position_y == 2 || dest_y - self.position_y == 1) && is_vertical_move?(dest_x, dest_y)
		  	else
		  		return true if dest_y - self.position_y == 1 && is_vertical_move?(dest_x, dest_y)
		  	end
		  elsif self.player_id == self.game.black_player_id # player black
		  	if self.move_count == 0
		  		return true if self.position_y - dest_y <= 2 && self.position_x == dest_x
		  	else
		  		return true if self.position_y - dest_y == 1 && self.position_x == dest_x
		  	end
		  end
		end
  	# todo movement for pawn capture

  	# en passant - own method?

  	# rook
  	if self.type == 'Rook' && (is_vertical_move?(dest_x, dest_y) || is_horizontal_move?(dest_x, dest_y))
  		return true 
  	end

  	# bishop
  	if self.type == 'Bishop' && is_diagonal_move?(dest_x, dest_y)
  		return true
  	end

		# knight
		if self.type == 'Knight' && is_knight_move?(dest_x, dest_y)
			return true 
		end

		# king
		if self.type == 'King' &&  (self.position_x - dest_x).abs <= 1 && (self.position_y - dest_y).abs <= 1
			return true
		end

		# castle - no pieces between, no check, rook and king haven't moved, prob own method

		# queen
		if self.type == 'Queen' && (is_diagonal_move?(dest_x, dest_y) || is_vertical_move?(dest_x, dest_y) || is_horizontal_move?(dest_x, dest_y))
			return true
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


end

