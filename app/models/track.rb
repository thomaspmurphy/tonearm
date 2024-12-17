class Track < ApplicationRecord
  belongs_to :record
  validates :title, presence: true
end
