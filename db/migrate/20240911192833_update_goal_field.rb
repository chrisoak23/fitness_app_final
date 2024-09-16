class UpdateGoalField < ActiveRecord::Migration[7.1]
  def change
    rename_column :goals, :goal, :name
  end
end
