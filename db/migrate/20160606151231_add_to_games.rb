class AddToGames < ActiveRecord::Migration
  def change
    add_column :games, :black_player_id, :integer
    add_column :games, :status, :string
    
  end
end
