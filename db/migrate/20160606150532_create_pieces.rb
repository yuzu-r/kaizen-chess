class CreatePieces < ActiveRecord::Migration
  def change
    create_table :pieces do |t|
      t.string  :type
      t.integer :position_x
      t.integer :position_y
      t.integer :game_id
      t.integer :player_id
      t.boolean :is_active
      t.integer :move_count
      t.boolean :is_selected
      t.timestamps null: false
    end
  end
end
