class CreateRecordGenres < ActiveRecord::Migration[8.0]
  def change
    create_table :record_genres do |t|
      t.references :record, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :record_genres, [:record_id, :genre_id], unique: true
  end
end
