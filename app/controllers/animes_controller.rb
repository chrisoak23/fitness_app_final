class AnimesController < ApplicationController
  PER_PAGE = 25

  def index
    @animes = Anime.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @anime = Anime.find_by(id: params[:id])

    if @anime.nil?
      flash[:alert] = "Anime not found"
      redirect_to animes_path
    end
  end

  def search
    if params[:query].present?
      # Use AniList API search
      @search_results = AnilistFetcher.new.search_anime_by_title(params[:query])
      @local_results = Anime.where("title ILIKE ?", "%#{params[:query]}%").limit(10)
    else
      @search_results = []
      @local_results = []
    end
  end

  def import_from_api
    anilist_id = params[:anilist_id].to_i
    anime = Anime.find_or_create_from_anilist(anilist_id)

    if anime
      redirect_to anime_path(anime), notice: 'Anime imported successfully!'
    else
      redirect_to search_animes_path, alert: 'Failed to import anime'
    end
  end

  def populate_with_top_anime
    fetcher = AnilistFetcher.new
    page = 1
    total_pages = 10 # import first 10 pages (~250 anime if 25 per page)

    while page <= total_pages
      response = fetcher.fetch_page(page, 25)
      media = response.dig("data", "Page", "media") || []

      media.each do |anime_data|
        title = anime_data.dig("title", "english") || anime_data.dig("title", "romaji")
        next if Anime.exists?(title: title)

        begin
          Anime.find_or_create_by(title: title) do |anime|
            anime.synopsis = ActionView::Base.full_sanitizer.sanitize(anime_data["description"])
            anime.episodes = anime_data["episodes"]
            anime.status = anime_data["status"]
            anime.image_url = anime_data.dig("coverImage", "large")

            if (d = anime_data["startDate"])
              anime.aired_from = Date.new(d["year"], d["month"] || 1, d["day"] || 1) rescue nil
            end
          end
        rescue => e
          Rails.logger.error "Failed to save anime: #{e.message}"
        end
      end

      page += 1
    end

    redirect_to animes_path, notice: "Anime imported!"
  end

end
