class UpdateUserGoalAssociation < ActiveRecord::Migration[7.1]
  def change
    add_index :goals, :user_id, unique: true
  end
end
