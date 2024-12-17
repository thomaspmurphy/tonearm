class RemoveGenreIdFromRecords < ActiveRecord::Migration[8.0]
  def change
    remove_reference :records, :genre, null: false, foreign_key: true
  end
end
