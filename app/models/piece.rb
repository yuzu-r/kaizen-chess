class Piece < ActiveRecord::Base
  belongs_to :player_id, class_name: "User"
  belongs_to :game
end

