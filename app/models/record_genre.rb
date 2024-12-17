class RecordGenre < ApplicationRecord
  belongs_to :record
  belongs_to :genre
end
