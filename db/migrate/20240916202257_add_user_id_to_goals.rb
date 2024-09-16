class AddUserIdToGoals < ActiveRecord::Migration[7.1]
  def change
    add_column :goals, :user_id, :int
  end
end
