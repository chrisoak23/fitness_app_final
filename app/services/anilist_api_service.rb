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
            media(type: ANIME, sort: $sort, isAdult: false) {
              id
              idMal
              title {
                romaji
                english
                native
                userPreferred
              }
              description
              episodes
              duration
              status
              averageScore
              meanScore
              popularity
              favourites
              trending
              genres
              season
              seasonYear
              format
              source
              studios {
                nodes {
                  name
                  isAnimationStudio
                }
              }
              countryOfOrigin
              isLicensed
              hashtag
              trailer {
                id
                site
                thumbnail
              }
              updatedAt
              coverImage {
                extraLarge
                large
                medium
                color
              }
              bannerImage
              tags {
                name
                description
                rank
                isMediaSpoiler
                isGeneralSpoiler
              }
              relations {
                edges {
                  node {
                    id
                    title {
                      romaji
                      english
                    }
                    format
                    type
                  }
                  relationType
                }
              }
              characters {
                edges {
                  node {
                    name {
                      full
                      native
                    }
                  }
                  role
                  voiceActors {
                    name {
                      full
                      native
                    }
                    language
                  }
                }
              }
              staff {
                edges {
                  node {
                    name {
                      full
                      native
                    }
                  }
                  role
                }
              }
              recommendations {
                nodes {
                  mediaRecommendation {
                    id
                    title {
                      romaji
                      english
                    }
                  }
                  rating
                }
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
              nextAiringEpisode {
                airingAt
                timeUntilAiring
                episode
              }
              airingSchedule {
                nodes {
                  episode
                  airingAt
                }
              }
              externalLinks {
                url
                site
                type
                language
                color
                icon
              }
              streamingEpisodes {
                title
                thumbnail
                url
                site
              }
              rankings {
                rank
                type
                format
                year
                season
                allTime
                context
              }
              stats {
                scoreDistribution {
                  score
                  amount
                }
                statusDistribution {
                  status
                  amount
                }
              }
              siteUrl
              autoCreateForumThread
              isRecommendationBlocked
              modNotes
              averageScore
              meanScore
              popularity
              trending
              favourites
              isFavourite
              isFavouriteBlocked
              isAdult
              mediaListEntry {
                id
                status
                score
                progress
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

    def get_all_anime(page = 1, per_page = 50)
      # Get ALL anime, not filtered by popularity
      query = <<-GRAPHQL
        query ($page: Int, $perPage: Int) {
          Page(page: $page, perPage: $perPage) {
            pageInfo {
              total
              currentPage
              lastPage
              hasNextPage
              perPage
            }
            media(type: ANIME, isAdult: false) {
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
        perPage: per_page
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

      request = Net::HTTP::Post.new('/')
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'

      request.body = {
        query: query,
        variables: variables
      }.to_json

      response = http.request(request)
      result = JSON.parse(response.body)
      Rails.logger.info "AniList API Response Status: #{response.code}"
      Rails.logger.info "AniList API Response: #{result.inspect}"
      result
    rescue => e
      Rails.logger.error "AniList API Error: #{e.message}"
      Rails.logger.error "AniList API Error Details: #{e.backtrace.first(5).join("\n")}"
      nil
    end

    def format_anime_response(response)
      # Return empty structure if response is invalid
      return { data: [], pagination: { 'items' => { 'total' => 0 } } } unless response

      # Check for GraphQL errors
      if response['errors']
        Rails.logger.error "AniList GraphQL errors: #{response['errors']}"
        return { data: [], pagination: { 'items' => { 'total' => 0 } } }
      end

      # Check for valid data structure
      return { data: [], pagination: { 'items' => { 'total' => 0 } } } unless response['data'] && response['data']['Page']

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
        'title_romaji' => anime['title']['romaji'],
        'title_english' => anime['title']['english'],
        'title_native' => anime['title']['native'],
        'synopsis' => anime['description']&.gsub(/<[^>]*>/, ''), # Remove HTML tags
        'episodes' => anime['episodes'],
        'episode_duration' => anime['duration'],
        'status' => map_status(anime['status']),
        'score' => anime['averageScore'] ? anime['averageScore'] / 10.0 : nil, # Convert from 100-point to 10-point scale
        'mean_score' => anime['meanScore'] ? anime['meanScore'] / 10.0 : nil,
        'popularity' => anime['popularity'],
        'favourites' => anime['favourites'],
        'trending' => anime['trending'],
        'genres' => anime['genres'] || [],
        'season' => anime['season'],
        'season_year' => anime['seasonYear'],
        'format' => anime['format'], # TV, MOVIE, OVA, ONA, SPECIAL, MUSIC
        'source' => anime['source'], # ORIGINAL, MANGA, LIGHT_NOVEL, etc
        'studios' => extract_studios(anime['studios']),
        'country_of_origin' => anime['countryOfOrigin'],
        'is_licensed' => anime['isLicensed'],
        'hashtag' => anime['hashtag'],
        'trailer' => anime['trailer'],
        'updated_at' => anime['updatedAt'],
        'cover_image_color' => anime.dig('coverImage', 'color'),
        'banner_image' => anime['bannerImage'],
        'tags' => extract_tags(anime['tags']),
        'relations' => extract_relations(anime['relations']),
        'characters' => extract_characters(anime['characters']),
        'staff' => extract_staff(anime['staff']),
        'recommendations' => extract_recommendations(anime['recommendations']),
        'next_airing_episode' => anime['nextAiringEpisode'],
        'airing_schedule' => anime['airingSchedule'],
        'external_links' => anime['externalLinks'],
        'streaming_episodes' => anime['streamingEpisodes'],
        'rankings' => anime['rankings'],
        'stats' => anime['stats'],
        'site_url' => anime['siteUrl'],
        'images' => {
          'jpg' => {
            'image_url' => anime.dig('coverImage', 'large') || anime.dig('coverImage', 'medium'),
            'large_image_url' => anime.dig('coverImage', 'extraLarge') || anime.dig('coverImage', 'large')
          }
        },
        'aired' => {
          'from' => format_date(anime['startDate']),
          'to' => format_date(anime['endDate'])
        }
      }
    end

    def extract_studios(studios)
      return [] unless studios && studios['nodes']
      studios['nodes'].select { |s| s['isAnimationStudio'] }.map { |s| s['name'] }
    end

    def extract_tags(tags)
      return [] unless tags
      tags.first(10).map do |tag|
        {
          'name' => tag['name'],
          'rank' => tag['rank'],
          'spoiler' => tag['isMediaSpoiler'] || tag['isGeneralSpoiler']
        }
      end
    end

    def extract_relations(relations)
      return [] unless relations && relations['edges']
      relations['edges'].map do |edge|
        {
          'id' => edge['node']['id'],
          'title' => edge['node']['title']['english'] || edge['node']['title']['romaji'],
          'type' => edge['relationType'],
          'format' => edge['node']['format']
        }
      end
    end

    def extract_characters(characters)
      return [] unless characters && characters['edges']
      characters['edges'].first(10).map do |edge|
        {
          'name' => edge['node']['name']['full'],
          'role' => edge['role'],
          'voice_actors' => edge['voiceActors']&.map { |va|
            {
              'name' => va['name']['full'],
              'language' => va['language']
            }
          }
        }
      end
    end

    def extract_staff(staff)
      return [] unless staff && staff['edges']
      staff['edges'].first(10).map do |edge|
        {
          'name' => edge['node']['name']['full'],
          'role' => edge['role']
        }
      end
    end

    def extract_recommendations(recommendations)
      return [] unless recommendations && recommendations['nodes']
      recommendations['nodes'].first(5).map do |rec|
        next unless rec['mediaRecommendation']
        {
          'id' => rec['mediaRecommendation']['id'],
          'title' => rec['mediaRecommendation']['title']['english'] || rec['mediaRecommendation']['title']['romaji'],
          'rating' => rec['rating']
        }
      end.compact
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