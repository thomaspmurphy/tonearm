require "open-uri"

class ImageDownloaderService
  def self.download(url)
    return nil if url.blank?

    begin
      URI.open(url)
    rescue OpenURI::HTTPError, SocketError => e
      Rails.logger.error "Failed to download image from #{url}: #{e.message}"
      nil
    end
  end
end
