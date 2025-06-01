class CreateAnimes < ActiveRecord::Migration[7.1]
  def change
    create_table :animes do |t|
      t.string :title
      t.text :synopsis
      t.integer :mal_id
      t.float :score
      t.integer :episodes
      t.string :status
      t.date :aired_from
      t.date :aired_to
      t.string :image_url

      t.timestamps
    end
  end
end
