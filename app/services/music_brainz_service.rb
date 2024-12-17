require "net/http"
require "json"
require "cgi"

class MusicBrainzService
  BASE_URL = "https://musicbrainz.org/ws/2"
  COVER_ART_URL = "https://coverartarchive.org"
  USER_AGENT = "Tonearm/1.0.0 ( thomaspmurphy@proton.me )"

  def self.search_release(query)
    return [] if query.blank?

    Rails.logger.info "Searching MusicBrainz for: #{query}"
    encoded_query = CGI.escape(query)
    uri = URI("#{BASE_URL}/release/?query=#{encoded_query}&fmt=json&limit=10")

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = USER_AGENT
    request["Accept"] = "application/json"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    return [] unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    releases = data["releases"] || []

    releases
      .select { |r| r["title"].present? && r["artist-credit"].present? }
      .map do |release|
        cover_art = fetch_cover_art(release["id"])
        next unless cover_art.present?

        {
          id: release["id"],
          title: release["title"],
          artist: release["artist-credit"]&.first&.dig("name"),
          year: release["date"]&.slice(0, 4),
          type: release["release-group"]&.dig("primary-type"),
          cover_art_url: cover_art
        }
      end.compact
  end

  def self.fetch_cover_art(mbid)
    uri = URI("#{COVER_ART_URL}/release/#{mbid}/front")
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = USER_AGENT

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPRedirection)
      # The API redirects to the actual image URL
      return response["location"]
    end

    # If we want thumbnails instead, we can try the -500 version
    uri = URI("#{COVER_ART_URL}/release/#{mbid}/front-500")
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = USER_AGENT

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    response["location"] if response.is_a?(Net::HTTPRedirection)
  rescue => e
    Rails.logger.error "Cover Art Archive error for #{mbid}: #{e.message}"
    nil
  end
end
