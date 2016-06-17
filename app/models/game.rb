class Game < ActiveRecord::Base
  belongs_to :white_player, class_name: "User"
  belongs_to :black_player, class_name: "User"
  has_many :pieces

def setup
  (1..8).each do |num|
    Pawn.create(game: self, player: self.white_player, position_x: num, position_y: 2)
  end 

  (1..8).each do |num|
    Pawn.create(game: self, player: self.black_player, position_x: num, position_y: 7)
  end 

  [1, 8].each do |num|
    Rook.create(game:self, player: self.white_player, position_x: num, position_y: 1)
  end 

  [1, 8].each do |num|
    Rook.create(game:self, player: self.black_player, position_x: num, position_y: 8)
  end 

  [2,7].each do |num|
    Knight.create(game:self, player: self.white_player, position_x: num, position_y: 1)
  end 

  [2,7].each do |num|
    Knight.create(game:self, player: self.black_player, position_x: num, position_y: 8)
  end 

  [3,6].each do |num|
    Bishop.create(game:self, player: self.white_player, position_x: num, position_y: 1)
  end 

  [3,6].each do |num|
    Bishop.create(game:self, player: self.black_player, position_x: num, position_y: 8)
  end 

  Queen.create(game:self, player: self.white_player, position_x: 4, position_y: 1)

  Queen.create(game:self, player: self.black_player, position_x: 4, position_y: 8)

  King.create(game:self, player: self.white_player, position_x: 5, position_y: 1)
  
  King.create(game:self, player: self.black_player, position_x: 5, position_y: 8)
end 

  def is_occupied?(dest_x, dest_y)
    pieces.where(position_x: dest_x, position_y: dest_y).first.present?
  end 

end
