class Game < ActiveRecord::Base
  belongs_to :white_player, class_name: "User"
  belongs_to :black_player, class_name: "User"
  belongs_to :active_player, class_name: "User"
  belongs_to :last_moved_piece, class_name: "Piece", foreign_key: "last_moved_piece_id"
  has_many :pieces
  validates :name, presence: true 
  validate :valid_active_player?

  def offer_draw(player_id)
    if player_id != self.white_player.id && player_id != self.black_player.id
      errors.add(:draw_offered_by_id, 'Invalid player!')
    else
      if draw_offered_by_id?
        errors.add(:draw_offered_by_id, 'Already in draw offered!')
      else
        if self.status != 'active'
          errors.add(:status, 'Game must be active in order to offer draw')
        else
          self.update_attribute(:draw_offered_by_id, player_id) 
        end
      end
    end
  end

  def rescind_draw(player_id)
    if player_id != self.draw_offered_by_id
      errors.add(:draw_offered_by_id, 'Player did not initiate draw.')
    else
      if self.status != 'active'
        errors.add(:status, 'Game is not active')
      else
        self.update_attribute(:draw_offered_by_id, nil)
      end
    end
  end

  def decline_draw(player_id)
    if player_id != self.white_player.id && player_id != self.black_player.id
      errors.add(:draw_offered_by_id, 'Invalid player!')
    else
      if player_id != self.draw_offered_by_id
        if self.status != 'active'
          errors.add(:status, 'Game is not active.')
        else
          self.update_attribute(:draw_offered_by_id, nil)
        end
      else
        errors.add(:draw_offered_by_id, 'Player initiated draw')
      end
    end
  end

  def accept_draw(player_id)
    if player_id != self.white_player.id && player_id != self.black_player.id
      errors.add(:draw_offered_by_id, 'Invalid player!')
    else
      if player_id != self.draw_offered_by_id
        if self.status != 'active'
          errors.add(:status, 'Game is not active.')
        else
          # update the game to mark it as a draw
          # game = finished and no winning/losing player means it was a draw
          if self.draw_offered_by_id
            self.update(status: "finished", active_player_id: nil, draw_offered_by_id: nil)
          else
            errors.add(:draw_offered_by_id, 'No draw to accept')
          end
        end
      else
        errors.add(:draw_offered_by_id, 'Player initiated draw')
      end
    end
  end

  def active_game_count
    Game.where(status: "active").count
  end

  def pending_game_count
    Game.where(status: "pending").count
  end

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

  def endangering_king?(player, moving_piece)
    # returns true if vacating a friendly piece at open_x, open_y leaves king open to check
    if player == white_player
      #logger.info("assessing endangerment(white)")
      king = pieces.where(type: "King", player: white_player).first
      king_x = king.position_x
      king_y = king.position_y
      # what kind of threat is activated by the potential move?
      open_x = moving_piece.position_x
      open_y = moving_piece.position_y
      #logger.info("king: #{king_x}, #{king_y}")
      #logger.info("open: #{open_x}, #{open_y}")
      black_player.pieces.where(game: self, is_active: true).each do |threat|
        #logger.info("assessing: #{threat.type} is: #{threat.position_x}, #{threat.position_y}")
        case threat.type
        when "Queen"
          if threat.position_y == king_y && threat.position_y == open_y && 
            (open_x.between?(king_x, threat.position_x) || open_x.between?(threat.position_x, king_x)) 
            # need to check if threat is in line with the king and the open space
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          elsif threat.position_x == king_x && threat.position_x == open_x &&
            (open_y.between?(king_y, threat.position_y) || open_y.between?(threat.position_y, king_y))
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          elsif threat.is_diagonal_move?(king_x, king_y) && threat.is_diagonal_move?(open_x, open_y) &&
            (open_x.between?(king_x, threat.position_x) || open_x.between?(threat.position_x, king_x)) &&
            (open_y.between?(king_y, threat.position_y) || open_y.between?(threat.position_y, king_y))
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          end 
        when "Rook"
          if threat.position_y == king_y && threat.position_y == open_y && 
            (open_x.between?(king_x, threat.position_x) || open_x.between?(threat.position_x, king_x)) 
            # need to check if threat is in line with the king and the open space
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          elsif threat.position_x == king_x && threat.position_x == open_x &&
            (open_y.between?(king_y, threat.position_y) || open_y.between?(threat.position_y, king_y))
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          end          
        when "Bishop"
          if threat.is_diagonal_move?(king_x, king_y) && threat.is_diagonal_move?(open_x, open_y) &&
            (open_x.between?(king_x, threat.position_x) || open_x.between?(threat.position_x, king_x)) &&
            (open_y.between?(king_y, threat.position_y) || open_y.between?(threat.position_y, king_y))
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          end
        end
      end
    else
      #logger.info("assessing endangerment")
      king = pieces.where(type: "King", player: black_player).first
      king_x = king.position_x
      king_y = king.position_y
      open_x = moving_piece.position_x
      open_y = moving_piece.position_y
      #logger.info("king: #{king_x}, #{king_y}")
      #logger.info("open: #{open_x}, #{open_y}")

      white_player.pieces.where(game: self, is_active: true).each do |threat|
        case threat.type
        when "Queen"
          #logger.info("threat is: #{threat.type}, #{threat.position_x}, #{threat.position_y}")
          # horizontal
          if threat.position_y == king_y && threat.position_y == open_y && 
            (open_x.between?(king_x, threat.position_x) || open_x.between?(threat.position_x, king_x)) 
            # need to check if threat is in line with the king and the open space
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          elsif threat.position_x == king_x && threat.position_x == open_x &&
            (open_y.between?(king_y, threat.position_y) || open_y.between?(threat.position_y, king_y))
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          elsif threat.is_diagonal_move?(king_x, king_y) && threat.is_diagonal_move?(open_x, open_y) &&
            (open_x.between?(king_x, threat.position_x) || open_x.between?(threat.position_x, king_x)) &&
            (open_y.between?(king_y, threat.position_y) || open_y.between?(threat.position_y, king_y))
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          end
        when "Rook"
          #logger.info("threat is: #{threat.type}, #{threat.position_x}, #{threat.position_y}")
          if threat.position_y == king_y && threat.position_y == open_y && 
            (open_x.between?(king_x, threat.position_x) || open_x.between?(threat.position_x, king_x)) 
            # need to check if threat is in line with the king and the open space
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          elsif threat.position_x == king_x && threat.position_x == open_x &&
            (open_y.between?(king_y, threat.position_y) || open_y.between?(threat.position_y, king_y))
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          end          
        when "Bishop"
          #logger.info("threat is: #{threat.type}, #{threat.position_x}, #{threat.position_y}")
          if threat.is_diagonal_move?(king_x, king_y) && threat.is_diagonal_move?(open_x, open_y) &&
            (open_x.between?(king_x, threat.position_x) || open_x.between?(threat.position_x, king_x)) &&
            (open_y.between?(king_y, threat.position_y) || open_y.between?(threat.position_y, king_y))
            return true if threat.clear_between?(open_x, open_y) && king.clear_between?(open_x, open_y)
          end
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
          threatening_piece = piece if piece.is_valid_move?(king_x, king_y)
        end
      end

      # Finds the friendly pieces that can block the threatening piece from checking the king
      white_player.pieces.where(game: self, is_active: true).each do |piece|
        return false if valid_check_block?(threatening_piece, piece, king) && piece.type != "King"
      end

      # find friendly pieces that can capture the threatening piece
      white_player.pieces.where(game: self, is_active: true).each do |piece|
        return false if valid_check_capture?(threatening_piece, piece, king)
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
          threatening_piece = piece if piece.is_valid_move?(king_x, king_y)
        end
      end

      # Finds the friendly pieces that can block the threatening piece from checking the king
      black_player.pieces.where(game: self, is_active: true).each do |piece|
        return false if valid_check_block?(threatening_piece, piece, king) && piece.type != "King"
      end

      # find friendly pieces that can capture the threatening piece
      black_player.pieces.where(game: self, is_active: true).each do |piece|
        return false if valid_check_capture?(threatening_piece, piece, king)
      end

      return true
    end
  end

  def valid_check_capture?(threatening_piece, piece, king)
    threatening_piece_x = threatening_piece.position_x
    threatening_piece_y = threatening_piece.position_y
    return true if piece.is_valid_move?(threatening_piece_x, threatening_piece_y)    
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

  def valid_check_defense?(threatening_piece, block_x, block_y, king)
    # this is like valid_check_block? but piece-agnostic
    # all it does is check if putting a piece at the coordinates will block a threat
    threatening_piece_x = threatening_piece.position_x
    threatening_piece_y = threatening_piece.position_y
    king_x = king.position_x
    king_y = king.position_y

    if threatening_piece.is_diagonal_move?(king_x, king_y)
      if threatening_piece_x < king_x && threatening_piece_y < king_y # SW
        (threatening_piece_x + 1).upto(king_x - 1) do |x|
          (threatening_piece_y + 1).upto(king_y - 1) do |y|
            return true if block_x == x && block_y == y && (x - threatening_piece.position_x).abs == (y - threatening_piece.position_y).abs
          end 
        end 
      elsif threatening_piece_x > king_x && threatening_piece_y < king_y # SE
        (threatening_piece_x - 1).downto(king_x + 1) do |x|
          (threatening_piece_y + 1).upto(king_y - 1) do |y|
            return true if block_x ==x && block_y == y && (x - threatening_piece.position_x).abs == (y - threatening_piece.position_y).abs
          end 
        end 
      elsif threatening_piece_x < king_x && threatening_piece_y > king_y # NW
        (threatening_piece_x + 1).upto(king_x - 1) do |x|
          (threatening_piece_y - 1).downto(king_y + 1) do |y|
            return true if block_x == x && block_y == y && (x - threatening_piece.position_x).abs == (y - threatening_piece.position_y).abs
          end 
        end 
      elsif threatening_piece_x > king_x && threatening_piece_y > king_y # NE
        (threatening_piece_x - 1).downto(king_x + 1) do |x|
         (threatening_piece_y - 1).downto(king_y + 1) do |y|
           return true if block_x == x && block_y == y && (x - threatening_piece.position_x).abs == (y - threatening_piece.position_y).abs
         end 
        end
      end  
    elsif threatening_piece.is_horizontal_move?(king_x, king_y)
      if threatening_piece_x < king_x # East
        (threatening_piece_x + 1).upto(king_x - 1) do |x|
          return true if block_y == threatening_piece_y && block_x == x
        end 
      else # West
        (threatening_piece_x - 1).downto(king_x + 1) do |x|
          return true if block_y == threatening_piece_y && block_x == x
        end 
      end 
    elsif threatening_piece.is_vertical_move?(king_x, king_y)
      if threatening_piece_y < king_y # North
        (threatening_piece_y + 1).upto(king_y - 1) do |y|
          return true if block_x == threatening_piece_x && block_y == y
        end 
      else # South
        (threatening_piece_y - 1).downto(king_y + 1) do |y|
          return true if block_x == threatening_piece_x && block_y == y
        end 
      end 
    elsif threatening_piece.is_knight_move?(king_x, king_y)
      # nothing can block a knight, out of luck
      return false
    end
    return false
  end

  def initialize_firebase
    game_status_msg = self.name + ': waiting for opponent'
    logger.info "writing to #{GAMES_URI}"
    response = FB.push(GAMES_URI, {id: self.id, game_status: self.status, status_message: game_status_msg, check_message: ""})
    self.update_attribute(:firebase_game_id, response.body["name"]) if response.success?
    logger.info "This game is #{response.body["name"]}"
  end

  def join_firebase
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    game_status_msg = self.name + ': active'
    FB.update(game_uri, {game_status: self.status, active_player_id: white_player.id, status_message: game_status_msg})
  end

  def in_check_firebase(player = nil)
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    if player
      if player == white_player
        check_message = "White (" + white_player.email + ") in check"
      else
        check_message = "Black (" + black_player.email + ") in check"
      end
    else
      check_message = ""
    end
    FB.update(game_uri, {check_message: check_message})
  end

  def update_active_player_firebase(player)
    # sets active player to the specified player
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    if player == white_player
      FB.update(game_uri, {active_player_id: white_player.id})
    else
      FB.update(game_uri, {active_player_id: black_player.id})
    end
  end

  def forfeit_firebase(player_id)
    # the player is the losing player in the game
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    if player_id == self.white_player.id
      game_status_msg = self.name + ': finished, ' + self.black_player.email + ' won'
    else
      game_status_msg = self.name + ': finished, ' + self.white_player.email + ' won'
    end
    FB.update(game_uri, {game_status: 'finished', active_player_id: "", status_message: game_status_msg})
  end

  def checkmated_firebase(player_id)
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    if player_id == self.white_player.id
      game_status_msg = self.name + ': white in checkmate, ' + self.black_player.email + ' won'
    else
      game_status_msg = self.name + ': black in checkmate, ' + self.white_player.email + ' won'
    end
    FB.update(game_uri, {game_status: 'finished', active_player_id: "", status_message: game_status_msg})
  end

  def draw_firebase
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    game_status_msg = self.name + ': draw' 
    FB.update(game_uri, {game_status: 'finished', active_player_id: "", status_message: game_status_msg})
  end

  def offer_draw_firebase(player_id)
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    if player_id == self.white_player.id
      draw_status_msg = 'White offers a draw. Black can accept or decline.'
    else
      draw_status_msg = 'Black offers a draw. White can accept or decline.'
    end
    FB.update(game_uri, {draw_message: draw_status_msg})
  end

  def decline_draw_firebase(player_id)
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    draw_status_msg = 'Draw offer was declined. Black or White can make a new draw offer.'
    FB.update(game_uri, {draw_message: draw_status_msg})
  end

  def rescind_draw_firebase(player_id)
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    draw_status_msg = 'Draw offer was withdrawn. Black or White can make a new draw offer.'
    FB.update(game_uri, {draw_message: draw_status_msg})   
  end

  def accept_draw_firebase(player_id)
    game_uri = GAMES_URI + self.firebase_game_id.to_s
    draw_status_msg = 'Draw accepted. The game is over.'
    status_message = self.name + ': finished (draw)'
    FB.update(game_uri, {game_status: 'finished', active_player_id: "", draw_message: draw_status_msg, status_message: status_message})       
  end
end
