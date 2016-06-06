class AddToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_alias, :string
  end
end
