# app/services/jikan_service.rb
class JikanService
  BASE_URL = 'https://api.jikan.moe/v4'

  def self.fetch_all_anime(page = 1)
    response = HTTParty.get("#{BASE_URL}/anime?page=#{page}")
    handle_response(response)
  end

  def self.fetch_anime_by_id(mal_id)
    response = HTTParty.get("#{BASE_URL}/anime/#{mal_id}")
    handle_response(response)
  end

  private

  def self.handle_response(response)
    if response.success?
      JSON.parse(response.body)['data']
    else
      Rails.logger.error "Jikan API Error: #{response.code} - #{response.body}"
      nil
    end
  rescue JSON::ParserError => e
    Rails.logger.error "JSON Parsing Error: #{e.message}"
    nil
  end
end