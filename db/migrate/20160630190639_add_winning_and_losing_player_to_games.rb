class AddWinningAndLosingPlayerToGames < ActiveRecord::Migration
  def change
    add_column :games, :winning_player, :integer
    add_column :games, :losing_player, :integer
  end
end
