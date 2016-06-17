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
    elsif #Diagonol movement
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

end

