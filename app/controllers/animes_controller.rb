# app/controllers/animes_controller.rb
class AnimesController < ApplicationController
  def index
    page = params[:page]&.to_i || 1
    per_page = 50  # AniList max is 50 per page
    sort = params[:sort] || 'POPULARITY_DESC'

    # Use different method for getting all anime
    if sort == 'ID' || sort == 'TITLE_ROMAJI'
      api_result = AnilistApiService.get_all_anime(page, per_page)
    else
      api_result = AnilistApiService.get_anime_page(page, per_page, sort)
    end

    # Check if API result is valid before accessing nested values
    if api_result && api_result[:data] && api_result[:pagination]
      # Debug logging
      Rails.logger.info "AniList API Response - Page: #{page}, Total: #{api_result[:pagination]['items']['total']}, Has Next: #{api_result[:pagination]['has_next_page']}"

      # Create or update anime records on the fly
      @anime_data = api_result[:data].map do |anime_data|
        anime = Anime.find_or_initialize_by(mal_id: anime_data['mal_id'])
        anime.assign_attributes(
          title: anime_data['title'],
          title_romaji: anime_data['title_romaji'],
          title_english: anime_data['title_english'],
          title_native: anime_data['title_native'],
          synopsis: anime_data['synopsis'],
          episodes: anime_data['episodes'],
          episode_duration: anime_data['episode_duration'],
          status: anime_data['status'],
          score: anime_data['score'],
          mean_score: anime_data['mean_score'],
          popularity: anime_data['popularity'],
          favourites: anime_data['favourites'],
          trending: anime_data['trending'],
          season: anime_data['season'],
          season_year: anime_data['season_year'],
          format: anime_data['format'],
          source: anime_data['source'],
          studios: anime_data['studios'],
          country_of_origin: anime_data['country_of_origin'],
          is_licensed: anime_data['is_licensed'],
          hashtag: anime_data['hashtag'],
          trailer_url: anime_data.dig('trailer', 'id'),
          trailer_thumbnail: anime_data.dig('trailer', 'thumbnail'),
          banner_image: anime_data['banner_image'],
          cover_image_color: anime_data['cover_image_color'],
          site_url: anime_data['site_url'],
          tags: anime_data['tags'] || {},
          external_links: anime_data['external_links'] || {},
          streaming_episodes: anime_data['streaming_episodes'] || {},
          rankings: anime_data['rankings'] || {},
          stats: anime_data['stats'] || {},
          image_url: anime_data.dig('images', 'jpg', 'image_url'),
          aired_from: parse_date(anime_data.dig('aired', 'from')),
          aired_to: parse_date(anime_data.dig('aired', 'to')),
          genres: anime_data['genres'] || []
        )
        anime.save if anime.changed?
        anime
      end

      # Create a paginated collection
      total_items = api_result[:pagination]['items']['total'] || @anime_data.length
      @animes = WillPaginate::Collection.create(page, per_page, total_items) do |pager|
        pager.replace(@anime_data)
      end
    else
      # API failed - fallback to database
      Rails.logger.error "AniList API failed or returned unexpected format"
      @animes = Anime.order(:title).paginate(page: page, per_page: per_page)
      flash.now[:alert] = "Unable to fetch from API, showing cached data" if @animes.any?
      flash.now[:alert] = "Unable to connect to anime database. Please try again later." if @animes.empty?
    end
  end

  def show
    @anime = Anime.find_by(id: params[:id])

    # If anime not found in database, try to fetch from API
    unless @anime
      # First try to find by AniList ID
      anime_data = AnilistApiService.get_anime_by_id(params[:id].to_i)
      if anime_data
        @anime = Anime.find_or_initialize_by(mal_id: anime_data['mal_id'])
        @anime.assign_attributes(
          title: anime_data['title'],
          synopsis: anime_data['synopsis'],
          episodes: anime_data['episodes'],
          status: anime_data['status'],
          score: anime_data['score'],
          image_url: anime_data.dig('images', 'jpg', 'image_url'),
          aired_from: parse_date(anime_data.dig('aired', 'from')),
          aired_to: parse_date(anime_data.dig('aired', 'to')),
          genres: anime_data['genres']
        )
        @anime.save if @anime.changed?
      end
    end

    redirect_to animes_path, alert: 'Anime not found' unless @anime
  end

  def search
    if params[:query].present?
      page = params[:page]&.to_i || 1
      per_page = 25

      # Search API directly
      api_result = AnilistApiService.search_anime(params[:query], page, per_page)

      if api_result && api_result[:data].present?
        # Process and save results
        @anime_data = api_result[:data].map do |anime_data|
          anime = Anime.find_or_initialize_by(mal_id: anime_data['mal_id'])
          anime.assign_attributes(
            title: anime_data['title'],
            synopsis: anime_data['synopsis'],
            episodes: anime_data['episodes'],
            status: anime_data['status'],
            score: anime_data['score'],
            image_url: anime_data.dig('images', 'jpg', 'image_url'),
            aired_from: parse_date(anime_data.dig('aired', 'from')),
            aired_to: parse_date(anime_data.dig('aired', 'to')),
            genres: extract_genres(anime_data['genres'])
          )
          anime.save if anime.changed?
          anime
        end

        # Create paginated results
        total_count = api_result[:pagination]['items']['total'] rescue @anime_data.length
        @results = WillPaginate::Collection.create(page, per_page, total_count) do |pager|
          pager.replace(@anime_data)
        end
      else
        # Fallback to local search
        @results = Anime.where("title ILIKE ?", "%#{params[:query]}%")
                        .order(:title)
                        .paginate(page: page, per_page: per_page)
      end
    else
      @results = Anime.none.paginate(page: 1, per_page: 25)
    end
  end

  private

  def parse_date(date_string)
    return nil if date_string.blank?
    DateTime.parse(date_string)
  rescue
    nil
  end
end