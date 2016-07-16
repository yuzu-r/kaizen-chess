class Game < ActiveRecord::Base
  belongs_to :white_player, class_name: "User"
  belongs_to :black_player, class_name: "User"
  belongs_to :active_player, class_name: "User"
  belongs_to :last_moved_piece, class_name: "Piece", foreign_key: "last_moved_piece_id"
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
      black_player.pieces.where(game: self, is_active: true).each do |piece|
        if piece.type != "King"
          return true if piece.is_valid_capture?(king_x, king_y) && piece.is_valid_move?(king_x, king_y)
        end
      end
    else
      king = pieces.where(type: "King", player: black_player).first
      king_x = king.position_x
      king_y = king.position_y
      white_player.pieces.where(game: self, is_active: true).each do |piece|
        if piece.type != "King"
          return true if piece.is_valid_capture?(king_x, king_y) && piece.is_valid_move?(king_x, king_y)
        end
      end
    end
    return false
  end

  def is_in_checkmate?(player)
    return false if !is_in_check?(player)
    if player == white_player
      king = pieces.where(type: "King", player: white_player).first
      return false if king.can_escape_from_check?

      # Finds the piece that is currently threatening the king
      king_x = king.position_x
      king_y = king.position_y
      threatening_piece = nil
      black_player.pieces.where(game: self, is_active: true).each do |piece|
        if piece.type != "King"
          threatening_piece = piece if piece.is_valid_capture?(king_x, king_y) && piece.is_valid_move?(king_x, king_y)
        end
      end

      # Finds the friendly pieces that can block the threatening piece from checking the king
      white_player.pieces.where(game: self, is_active: true).each do |piece|
        return false if valid_check_block?(threatening_piece, piece, king) && piece.type != "King"
      end
      return true
    else
      king = pieces.where(type: "King", player: black_player).first
      return false if king.can_escape_from_check?

      # Finds the piece that is currently threatening the king
      king_x = king.position_x
      king_y = king.position_y
      threatening_piece = nil
      white_player.pieces.where(game: self, is_active: true).each do |piece|
        if piece.type != "King"
          threatening_piece = piece if piece.is_valid_capture?(king_x, king_y) && piece.is_valid_move?(king_x, king_y)
        end
      end

      # Finds the friendly pieces that can block the threatening piece from checking the king
      black_player.pieces.where(game: self, is_active: true).each do |piece|
        return false if valid_check_block?(threatening_piece, piece, king) && piece.type != "King"
      end

      return true
    end
  end

  def valid_check_block?(threatening_piece, piece, king)
    threatening_piece_x = threatening_piece.position_x
    threatening_piece_y = threatening_piece.position_y
    king_x = king.position_x
    king_y = king.position_y

    if threatening_piece.is_diagonal_move?(king_x, king_y)
      if threatening_piece_x < king_x && threatening_piece_y < king_y # Northeast
        (threatening_piece_x + 1).upto(king_x - 1) do |x|
          (threatening_piece_y + 1).upto(king_y - 1) do |y|
            return true if piece.is_valid_move?(x, y) && (x - threatening_piece.position_x).abs == (y - threatening_piece.position_y).abs
          end 
        end 
      elsif threatening_piece_x > king_x && threatening_piece_y < king_y # Northwest
        (threatening_piece_x - 1).downto(king_x + 1) do |x|
          (threatening_piece_y + 1).upto(king_y - 1) do |y|
            return true if piece.is_valid_move?(x, y) && (x - threatening_piece.position_x).abs == (y - threatening_piece.position_y).abs
          end 
        end 
      elsif threatening_piece_x < king_x && threatening_piece_y > king_y # Southeast
        (threatening_piece_x + 1).upto(king_x - 1) do |x|
          (threatening_piece_y - 1).downto(king_y + 1) do |y|
            return true if piece.is_valid_move?(x, y) && (x - threatening_piece.position_x).abs == (y - threatening_piece.position_y).abs
          end 
        end 
      elsif threatening_piece_x > king_x && threatening_piece_y > king_y # Southwest
        (threatening_piece_x - 1).downto(king_x + 1) do |x|
          (threatening_piece_y - 1).downto(king_y + 1) do |y|
            return true if piece.is_valid_move?(x, y) && (x - threatening_piece.position_x).abs == (y - threatening_piece.position_y).abs
          end 
        end
      end  
    elsif threatening_piece.is_horizontal_move?(king_x, king_y)
      if threatening_piece_x < king_x # East
        (threatening_piece_x + 1).upto(king_x - 1) do |x|
          return true if piece.is_valid_move?(x, king_y)
        end 
      else # West
        (threatening_piece_x - 1).downto(king_x + 1) do |x|
          return true if piece.is_valid_move?(x, king_y)
        end 
      end 
    elsif threatening_piece.is_vertical_move?(king_x, king_y)
      if threatening_piece_y < king_y # North
        (threatening_piece_y + 1).upto(king_y - 1) do |y|
          return true if piece.is_valid_move?(king_x, y)
        end 
      else # South
        (threatening_piece_y - 1).downto(king_y + 1) do |y|
          return true if piece.is_valid_move?(king_x, y)
        end 
      end 
    elsif threatening_piece.is_knight_move?(king_x, king_y)
      return false
    end
    false
  end 

end
