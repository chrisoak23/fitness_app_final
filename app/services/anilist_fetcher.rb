require 'httparty'

class AnilistFetcher
  API_URL = 'https://graphql.anilist.co'

  # Fetch a paginated list of anime
  def fetch_page(page = 1, per_page = 50)
    query = <<~GRAPHQL
      query ($page: Int, $perPage: Int) {
        Page(page: $page, perPage: $perPage) {
          pageInfo {
            hasNextPage
          }
          media(type: ANIME) {
            id
            title {
              romaji
              english
              native
            }
            description
            episodes
            status
            startDate {
              year
              month
              day
            }
            coverImage {
              large
            }
          }
        }
      }
    GRAPHQL

    HTTParty.post(API_URL,
                  headers: { 'Content-Type' => 'application/json' },
                  body: {
                    query: query,
                    variables: { page: page, perPage: per_page }
                  }.to_json
    ).parsed_response
  end

  # Fetch a single anime by AniList ID
  def fetch_anime_by_id(id)
    query = <<~GRAPHQL
      query ($id: Int) {
        Media(id: $id, type: ANIME) {
          id
          title {
            romaji
            english
            native
          }
          description
          episodes
          status
          startDate {
            year
            month
            day
          }
          coverImage {
            large
          }
        }
      }
    GRAPHQL

    HTTParty.post(API_URL,
                  headers: { 'Content-Type' => 'application/json' },
                  body: {
                    query: query,
                    variables: { id: id }
                  }.to_json
    ).parsed_response
  end

  # Search for anime by title
  def search_anime_by_title(query_text)
    query = <<~GRAPHQL
      query ($search: String) {
        Page(page: 1, perPage: 10) {
          media(search: $search, type: ANIME) {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
          }
        }
      }
    GRAPHQL

    HTTParty.post(API_URL,
                  headers: { 'Content-Type' => 'application/json' },
                  body: {
                    query: query,
                    variables: { search: query_text }
                  }.to_json
    ).parsed_response.dig("data", "Page", "media") || []
  end

  # Fetch top anime sorted by popularity
  def fetch_top_anime(limit = 100)
    query = <<~GRAPHQL
      query ($perPage: Int) {
        Page(page: 1, perPage: $perPage) {
          media(sort: POPULARITY_DESC, type: ANIME) {
            id
            title {
              english
              romaji
            }
            description
            episodes
            status
            startDate {
              year
              month
              day
            }
            coverImage {
              large
            }
          }
        }
      }
    GRAPHQL

    HTTParty.post(API_URL,
                  headers: { 'Content-Type' => 'application/json' },
                  body: {
                    query: query,
                    variables: { perPage: limit }
                  }.to_json
    ).parsed_response.dig("data", "Page", "media") || []
  end
end
