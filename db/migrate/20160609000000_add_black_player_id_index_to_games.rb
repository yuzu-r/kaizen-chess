class AddBlackPlayerIdIndexToGames < ActiveRecord::Migration
  def change
    add_index :games, :black_player_id
  end
end
