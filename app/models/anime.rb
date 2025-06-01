class Anime < ApplicationRecord
  def self.find_or_create_from_anilist(anilist_id)
    fetcher = AnilistFetcher.new
    response = fetcher.fetch_anime_by_id(anilist_id)

    return nil unless response && response["data"] && response["data"]["Media"]

    anime_data = response["data"]["Media"]

    find_or_create_by(title: anime_data.dig("title", "english") || anime_data.dig("title", "romaji")) do |anime|
      anime.synopsis = ActionView::Base.full_sanitizer.sanitize(anime_data["description"])
      anime.episodes = anime_data["episodes"]
      anime.status = anime_data["status"]
      anime.image_url = anime_data.dig("coverImage", "large")

      if (d = anime_data["startDate"])
        anime.aired_from = Date.new(d["year"], d["month"] || 1, d["day"] || 1) rescue nil
      end
    end
  end
end
