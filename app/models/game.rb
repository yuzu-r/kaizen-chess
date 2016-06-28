class Game < ActiveRecord::Base
  belongs_to :white_player, class_name: "User"
  belongs_to :black_player, class_name: "User"
  belongs_to :active_player, class_name: "User"
  has_many :pieces

  validate :valid_active_player?

  def valid_active_player?
    if active_player
      if (active_player != white_player) && (active_player != black_player)
        errors.add(:active_player,'Invalid active player!')
      end
    end
  end

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

  def is_in_check?(player)
    # currently assumes that there is a king on the board for the player in question
    # also assumes the game has both a white and black player
    return false if white_player != player && black_player != player
    if player == white_player
      king = pieces.where(type: "King", player: white_player).first
      king_x = king.position_x
      king_y = king.position_y
      black_player.pieces.where(is_active: true).each do |piece|
        return true if piece.is_valid_capture?(king_x, king_y) && piece.is_valid_move?(king_x, king_y)
      end
    else
      king = pieces.where(type: "King", player: black_player).first
      king_x = king.position_x
      king_y = king.position_y
      white_player.pieces.where(is_active: true).each do |piece|
        return true if piece.is_valid_capture?(king_x, king_y) && piece.is_valid_move?(king_x, king_y)
      end
    end
    return false
  end

end
