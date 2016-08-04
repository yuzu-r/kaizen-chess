class AddDrawToGame < ActiveRecord::Migration
  def change
    add_column :games, :draw_offered_by_id, :integer
  end
end
