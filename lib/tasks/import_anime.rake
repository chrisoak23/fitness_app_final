namespace :anime do
  desc "Import anime from AniList API"
  task import: :environment do
    fetcher = AnilistFetcher.new
    page = 1

    loop do
      puts "Fetching page #{page}..."
      data = fetcher.fetch_page(page)

      media = data.dig("data", "Page", "media")
      break unless media

      media.each do |anime_data|
        title = anime_data.dig("title", "english") || anime_data.dig("title", "romaji")
        description = ActionView::Base.full_sanitizer.sanitize(anime_data["description"])
        year = anime_data.dig("startDate", "year")

        Anime.find_or_create_by(title: title) do |anime|
          anime.synopsis = description
          anime.aired_from = "#{year}-01-01" if year.present?
        end
      end

      break unless data.dig("data", "Page", "pageInfo", "hasNextPage")
      page += 1
    end

    puts "Done importing."
  end
end
