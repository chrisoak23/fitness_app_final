class CreateUserTrainers < ActiveRecord::Migration[7.1]
  def change
    create_table :user_trainers do |t|
      t.integer :user_id
      t.integer :trainer_id
    end
  end
end
