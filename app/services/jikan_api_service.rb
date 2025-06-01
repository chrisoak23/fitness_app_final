# app/services/jikan_api_service.rb
class JikanApiService
  include HTTParty
  base_uri 'https://api.jikan.moe/v4'
  DEFAULT_LIMIT = 25
  MAX_LIMIT = 250 # Jikan API's maximum per request

  def self.get_anime(anime_id)
    response = get("/anime/#{anime_id}")
    if response.success?
      response.parsed_response['data']
    else
      nil
    end
  end

  def self.search_anime(query, limit = DEFAULT_LIMIT, page = 1)
    response = get("/anime", query: {
      q: query,
      limit: [limit, MAX_LIMIT].min,
      page: page
    })
    response.success? ? response.parsed_response['data'] : []
  end

  def self.get_top_anime(limit = DEFAULT_LIMIT, page = 1)
    response = get("/top/anime", query: {
      limit: [limit, MAX_LIMIT].min,
      page: page
    })
    response.success? ? response.parsed_response['data'] : []
  end

  def self.get_seasonal_anime(year = Date.current.year, season = current_season, page = 1)
    response = get("/seasons/#{year}/#{season}", query: { page: page })
    response.success? ? response.parsed_response['data'] : []
  end

  private

  def self.current_season
    month = Date.current.month
    case month
    when 12, 1, 2
      'winter'
    when 3, 4, 5
      'spring'
    when 6, 7, 8
      'summer'
    when 9, 10, 11
      'fall'
    end
  end
end