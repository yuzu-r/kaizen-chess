class AddDefaultValuesToPieces < ActiveRecord::Migration
  def change
    change_column_default :pieces, :is_active, true
    change_column_default :pieces, :is_selected, false
    change_column_default :pieces, :move_count, 0
  end
end
