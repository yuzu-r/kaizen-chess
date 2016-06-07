class ChangeUserColumn < ActiveRecord::Migration
  def change
    rename_column :games, :user_id, :white_player_id
  end
end
