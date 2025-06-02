# app/services/jikan_api_service.rb
class JikanApiService
  include HTTParty
  base_uri 'https://api.jikan.moe/v4'

  def self.get_anime(anime_id)
    response = get("/anime/#{anime_id}")
    if response.success?
      response.parsed_response['data']
    else
      nil
    end
  end

  def self.search_anime(query, limit = 10)
    response = get("/anime", query: { q: query, limit: limit })
    if response.success?
      response.parsed_response['data']
    else
      []
    end
  end

  def self.get_top_anime(limit = 25, page = 1)
    response = get("/top/anime", query: { limit: limit, page: page })
    if response.success?
      {
        data: response.parsed_response['data'],
        pagination: response.parsed_response['pagination']
      }
    else
      { data: [], pagination: {} }
    end
  end

  def self.get_all_anime_by_genre(genre_id = nil, limit = 25, page = 1)
    params = { limit: limit, page: page, order_by: 'popularity' }
    params[:genres] = genre_id if genre_id

    response = get("/anime", query: params)
    if response.success?
      {
        data: response.parsed_response['data'],
        pagination: response.parsed_response['pagination']
      }
    else
      { data: [], pagination: {} }
    end
  end

  def self.bulk_import_top_anime(total_pages = 10)
    imported_count = 0

    (1..total_pages).each do |page|
      result = get_top_anime(25, page)

      result[:data].each do |anime_data|
        next if Anime.exists?(mal_id: anime_data['mal_id'])

        begin
          Anime.create_from_api_data(anime_data)
          imported_count += 1
        rescue => e
          Rails.logger.error "Failed to create anime #{anime_data['title']}: #{e.message}"
        end
      end

      # Respect API rate limits (3 requests per second)
      sleep(0.5)

      break unless result[:pagination]['has_next_page']
    end

    imported_count
  end

  def self.get_seasonal_anime(year = Date.current.year, season = current_season)
    response = get("/seasons/#{year}/#{season}")
    if response.success?
      response.parsed_response['data']
    else
      []
    end
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