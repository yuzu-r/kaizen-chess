class AddDefaultToStatus < ActiveRecord::Migration
  def change
    change_column_default :games, :status, "pending"
  end
end
