class CreateRankings < ActiveRecord::Migration[7.1]
  def change
    create_table :rankings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :anime, null: false, foreign_key: true
      t.decimal :score
      t.text :comment

      t.timestamps
    end
  end
end
