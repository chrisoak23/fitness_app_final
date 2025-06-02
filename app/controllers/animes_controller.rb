# app/controllers/animes_controller.rb
class AnimesController < ApplicationController
  def index
    page = params[:page]&.to_i || 1
    per_page = 25

    # Always fetch from API to get the latest data
    api_result = JikanApiService.get_top_anime(per_page, page)

    if api_result[:data].present?
      # Create or update anime records on the fly
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

      # Create a paginated collection
      @animes = WillPaginate::Collection.create(page, per_page, api_result[:pagination]['items']['total']) do |pager|
        pager.replace(@anime_data)
      end
    else
      # Fallback to database if API fails
      @animes = Anime.order(:title).paginate(page: page, per_page: per_page)
      flash.now[:alert] = "Unable to fetch from API, showing cached data" if @animes.any?
    end
  end

  def show
    @anime = Anime.find_by(id: params[:id])

    # If anime not found in database, try to fetch from API using MAL ID
    unless @anime
      mal_id = params[:id].to_i
      @anime = Anime.find_or_create_from_api(mal_id)
    end

    redirect_to animes_path, alert: 'Anime not found' unless @anime
  end

  def search
    if params[:query].present?
      page = params[:page]&.to_i || 1
      per_page = 25

      # Search API directly
      api_result = JikanApiService.search_anime(params[:query], per_page, page)

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

  def extract_genres(genres_array)
    return [] unless genres_array.is_a?(Array)
    genres_array.map { |genre| genre['name'] }.compact
  end
end