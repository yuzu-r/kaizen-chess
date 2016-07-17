class AddFirebaseKeyToGames < ActiveRecord::Migration
  def change
    add_column :games, :firebase_game_id, :string
  end
end
