class Piece < ActiveRecord::Base
  belongs_to :player, class_name: "User"
  belongs_to :game

  def is_obstructed?(dest_x, dest_y)
    return true if self.game.is_occupied?(dest_x, dest_y) && self.player == self.game.pieces.where(position_x:dest_x, position_y: dest_y).first.player
    if self.position_y == dest_y #Horizontal
      if self.position_x < dest_x
        (position_x + 1.. dest_x - 1).each do |x|
          return true if self.game.is_occupied?(x, dest_y)
        end 
      else
        (position_x - 1.. dest_x + 1).each do |x|
          return true if self.game.is_occupied?(x, dest_y)
        end 
      end 
    elsif self.position_x == dest_x #Vertical
      if self.position_y < dest_y
        (position_y + 1.. dest_y - 1).each do |y|
          return true if self.game.is_occupied?(dest_x, y)
        end 
      else
        (position_y - 1 .. dest_y + 1).each do |y|
          return true if self.game.is_occupied?(dest_x, y)
        end 
      end 
    elsif #Diagonol
      if self.position_x < dest_x && self.position_y < dest_y
        (position_x + 1.. dest_x - 1).each do |x|
          (position_y + 1.. dest_y - 1).each do |y|
            return true if self.game.is_occupied?(x, y) && (x - position_x).abs == (y - position_y).abs
          end 
        end 
      elsif self.position_x > dest_x && self.position_y < dest_y
        (position_x - 1.. dest_x + 1).each do |x|
          (position_y + 1.. dest_y - 1).each do |y|
            return true if self.game.is_occupied?(x, y) && (x - position_x).abs == (y - position_y).abs
          end 
        end 
      elsif self.position_x < dest_x && self.position_y > dest_y
        (position_x + 1.. dest_x - 1).each do |x|
          (position_y - 1.. dest_y + 1).each do |y|
            return true if self.game.is_occupied?(x, y) && (x - position_x).abs == (y - position_y).abs
          end 
        end 
      elsif self.position_x > dest_x && self.position_y > dest_y
        (position_x - 1.. dest_x + 1).each do |x|
          (position_y - 1.. dest_y + 1).each do |y|
            return true if self.game.is_occupied?(x, y) && (x - position_x).abs == (y - position_y).abs
          end 
        end
      end   
    end 
    false
  end 

end

