# GenresController handles actions related to genres.
class GenresController < ApplicationController
  # Searches for genres based on a query parameter.
  #
  # @return [JSON] a JSON array of matching genres (max 10), each containing an id and name.
  def search
    query = params[:query].to_s.strip
    genres = Genre.where("name ILIKE ?", "%#{query}%").limit(10)
    render json: genres.map { |genre| { id: genre.id, name: genre.name } }
  end
end
