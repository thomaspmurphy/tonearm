class Record < ApplicationRecord
  belongs_to :artist
  has_many :record_genres
  has_many :genres, through: :record_genres
  has_one_attached :cover_image

  validates :title, presence: true
  validates :artist, presence: true
  validates :release_year, numericality: { only_integer: true, allow_nil: true }
  validate :maximum_genres

  attr_accessor :artist_name, :cover_art_url, :genre_names

  # Enums
  enum :format, {
    "LP" => 0,
    '12"' => 1,
    '10"' => 2,
    '7"' => 3,
    "CD" => 4,
    "Cassette" => 5,
    "Digital" => 6
  }

  enum :condition, {
    "Mint" => 0,
    "Near Mint" => 1,
    "Very Good Plus" => 2,
    "Very Good" => 3,
    "Good" => 4,
    "Fair" => 5,
    "Poor" => 6
  }

  # Callbacks
  before_validation :set_artist
  after_create :attach_cover_from_url
  before_save :process_genre_names

  private

  def set_artist
    if artist_name.present?
      self.artist = Artist.find_or_create_by!(name: artist_name.strip)
    end
  end

  def attach_cover_from_url
    return unless cover_art_url.present?

    downloaded_image = ImageDownloaderService.download(cover_art_url)
    if downloaded_image
      cover_image.attach(
        io: downloaded_image,
        filename: "cover-#{SecureRandom.hex(8)}.jpg",
        content_type: "image/jpeg"
      )
    end
  rescue => e
    Rails.logger.error "Failed to attach cover image: #{e.message}"
  end

  def process_genre_names
    return unless genre_names.present?

    names = genre_names.split(",").map(&:strip)

    self.genres = names.map { |name| Genre.find_or_create_by!(name: name) }
  end

  def maximum_genres
    if genres.length > 3
      errors.add(:genres, "cannot have more than 3 genres")
    end
  end
end
