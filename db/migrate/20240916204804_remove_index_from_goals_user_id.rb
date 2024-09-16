class RemoveIndexFromGoalsUserId < ActiveRecord::Migration[7.1]
  def change
    remove_index :goals, column: :user_id, unique: true
  end
end