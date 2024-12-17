class RecordsController < ApplicationController
  def index
    @records = Record.includes(:artist)

    @records = case params[:sort]
    when "title"
      @records.order(title: params[:direction])
    when "artist"
      @records.joins(:artist).order("artists.name #{params[:direction]}")
    when "year"
      @records.order(release_year: params[:direction])
    else
      @records.order(created_at: :desc)
    end

    respond_to do |format|
      format.html
      format.turbo_stream {
        render turbo_stream: turbo_stream.update("records",
          partial: "records/records",
          locals: { records: @records }
        )
      }
    end
  end

  def show
    @record = Record.find(params[:id])
  end

  def new
    @record = Record.new
  end

  def create
    @record = Record.new(record_params)

    if @record.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("records", partial: "records/record", locals: { record: @record }),
            turbo_stream.update("modal", "")
          ]
        end
        format.html { redirect_to records_path, notice: "Record was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def search
    @releases = MusicBrainzService.search_release(params[:query])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "search-results",
          partial: "records/search_results",
          locals: { releases: @releases }
        )
      end
    end
  end

  def fetch_release
    mbid = params[:mbid]
    return render json: { error: "Missing MBID" }, status: :bad_request if mbid.blank?

    begin
      release = MusicBrainzService.fetch_release(mbid)

      if release
        render json: {
          title: release[:title],
          artist: release[:artist],
          year: release[:year],
          cover_art_url: release[:cover_art_url]
        }
      else
        render json: { error: "Release not found" }, status: :not_found
      end
    rescue => e
      Rails.logger.error("MusicBrainz fetch error: #{e.message}")
      Rails.logger.error
      render json: { error: e.message }, status: :service_unavailable
    end
  end

  def fetch_cover
    @record = Record.find(params[:id])
    success = false

    Rails.logger.info "Fetching cover for record: #{@record.title} by #{@record.artist.name}"

    # Search MusicBrainz for the release
    results = MusicBrainzService.search_release("#{@record.title} #{@record.artist.name}")
    Rails.logger.info "Search results: #{results.inspect}"

    if results.present?
      results.each do |result|
        next unless result[:cover_art_url].present?
        Rails.logger.info "Attempting to download cover from: #{result[:cover_art_url]}"

        downloaded_image = ImageDownloaderService.download(result[:cover_art_url])
        if downloaded_image
          @record.cover_image.attach(
            io: downloaded_image,
            filename: "cover-#{SecureRandom.hex(8)}.jpg",
            content_type: "image/jpeg"
          )
          success = true
          Rails.logger.info "Successfully attached cover image"
          break
        end
      end
    end

    respond_to do |format|
      format.turbo_stream {
        if success
          render turbo_stream: turbo_stream.replace(@record, partial: "records/record", locals: { record: @record })
        else
          Rails.logger.error "No cover art found or failed to attach"
          render turbo_stream: turbo_stream.replace(@record, partial: "records/record", locals: { record: @record })
        end
      }
      format.html { redirect_to records_path, notice: success ? "Cover art updated" : "No cover art found" }
    end
  end

  def edit
    @record = Record.find(params[:id])
  end

  def update
    @record = Record.find(params[:id])

    if @record.update(record_params)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(@record),
            turbo_stream.remove("modal")
          ]
        }
        format.html { redirect_to records_path, notice: "Record was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record = Record.find(params[:id])
    @record.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@record) }
      format.html { redirect_to records_path, notice: "Record was successfully removed." }
    end
  end

  private

  def record_params
    params.require(:record).permit(:title, :artist_name, :release_year, :format, :cover_image, genre_ids: []).tap do |whitelisted|
      whitelisted[:genre_ids] = process_genre_ids(whitelisted[:genre_ids]) if whitelisted[:genre_ids].present?
    end
  end

  # Processes an array of genre IDs, handling both existing genre IDs (integers)
  # and new genre names (strings). For new genres, creates them in the database.
  # Returns an array of genre IDs.
  def process_genre_ids(genre_ids)
    genre_ids.reject(&:blank?).map do |id|
      id.to_i.zero? ? Genre.find_or_create_by!(name: id.strip).id : id.to_i
    end
  end
end
