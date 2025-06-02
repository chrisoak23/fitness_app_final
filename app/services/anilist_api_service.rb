# app/services/anilist_api_service.rb
require 'net/http'
require 'json'

class AnilistApiService
  BASE_URL = 'https://graphql.anilist.co'

  class << self
    def get_anime_page(page = 1, per_page = 50, sort = 'POPULARITY_DESC')
      # AniList has a max of 50 per page
      per_page = [per_page, 50].min

      query = <<-GRAPHQL
        query ($page: Int, $perPage: Int, $sort: [MediaSort]) {
          Page(page: $page, perPage: $perPage) {
            pageInfo {
              total
              currentPage
              lastPage
              hasNextPage
              perPage
            }
            media(type: ANIME, sort: $sort) {
              id
              idMal
              title {
                romaji
                english
                native
              }
              description
              episodes
              status
              averageScore
              genres
              coverImage {
                large
                medium
              }
              startDate {
                year
                month
                day
              }
              endDate {
                year
                month
                day
              }
            }
          }
        }
      GRAPHQL

      variables = {
        page: page,
        perPage: per_page,
        sort: sort
      }

      response = make_request(query, variables)
      format_anime_response(response)
    end

    def search_anime(search_term, page = 1, per_page = 25)
      query = <<-GRAPHQL
        query ($search: String, $page: Int, $perPage: Int) {
          Page(page: $page, perPage: $perPage) {
            pageInfo {
              total
              currentPage
              lastPage
              hasNextPage
              perPage
            }
            media(search: $search, type: ANIME) {
              id
              idMal
              title {
                romaji
                english
                native
              }
              description
              episodes
              status
              averageScore
              genres
              coverImage {
                large
                medium
              }
              startDate {
                year
                month
                day
              }
              endDate {
                year
                month
                day
              }
            }
          }
        }
      GRAPHQL

      variables = {
        search: search_term,
        page: page,
        perPage: per_page
      }

      response = make_request(query, variables)
      format_anime_response(response)
    end

    def get_anime_by_id(anilist_id)
      query = <<-GRAPHQL
        query ($id: Int) {
          Media(id: $id, type: ANIME) {
            id
            idMal
            title {
              romaji
              english
              native
            }
            description
            episodes
            status
            averageScore
            genres
            coverImage {
              large
              medium
            }
            startDate {
              year
              month
              day
            }
            endDate {
              year
              month
              day
            }
          }
        }
      GRAPHQL

      variables = { id: anilist_id }
      response = make_request(query, variables)

      if response && response['data'] && response['data']['Media']
        format_single_anime(response['data']['Media'])
      else
        nil
      end
    end

    private

    def make_request(query, variables = {})
      uri = URI(BASE_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'

      request.body = {
        query: query,
        variables: variables
      }.to_json

      response = http.request(request)
      JSON.parse(response.body)
    rescue => e
      Rails.logger.error "AniList API Error: #{e.message}"
      nil
    end

    def format_anime_response(response)
      return { data: [], pagination: {} } unless response && response['data'] && response['data']['Page']

      page_info = response['data']['Page']['pageInfo']
      anime_list = response['data']['Page']['media'] || []

      {
        data: anime_list.map { |anime| format_single_anime(anime) },
        pagination: {
          'current_page' => page_info['currentPage'],
          'last_page' => page_info['lastPage'],
          'has_next_page' => page_info['hasNextPage'],
          'per_page' => page_info['perPage'],
          'items' => {
            'total' => page_info['total']
          }
        }
      }
    end

    def format_single_anime(anime)
      {
        'mal_id' => anime['idMal'] || anime['id'], # Use AniList ID if MAL ID not available
        'anilist_id' => anime['id'],
        'title' => anime['title']['english'] || anime['title']['romaji'] || anime['title']['native'],
        'synopsis' => anime['description']&.gsub(/<[^>]*>/, ''), # Remove HTML tags
        'episodes' => anime['episodes'],
        'status' => map_status(anime['status']),
        'score' => anime['averageScore'] ? anime['averageScore'] / 10.0 : nil, # Convert from 100-point to 10-point scale
        'genres' => anime['genres'] || [],
        'images' => {
          'jpg' => {
            'image_url' => anime['coverImage']['large'] || anime['coverImage']['medium']
          }
        },
        'aired' => {
          'from' => format_date(anime['startDate']),
          'to' => format_date(anime['endDate'])
        }
      }
    end

    def map_status(status)
      case status
      when 'FINISHED'
        'Finished Airing'
      when 'RELEASING'
        'Currently Airing'
      when 'NOT_YET_RELEASED'
        'Not yet aired'
      when 'CANCELLED'
        'Cancelled'
      else
        status
      end
    end

    def format_date(date_hash)
      return nil unless date_hash && date_hash['year']

      year = date_hash['year']
      month = date_hash['month'] || 1
      day = date_hash['day'] || 1

      "#{year}-#{month.to_s.rjust(2, '0')}-#{day.to_s.rjust(2, '0')}"
    rescue
      nil
    end
  end
end