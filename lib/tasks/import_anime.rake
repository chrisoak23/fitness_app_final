# lib/tasks/anime_import.rake
namespace :anime do
  desc "Import top anime from MyAnimeList"
  task import_top: :environment do
    puts "Starting anime import..."

    imported_count = JikanApiService.bulk_import_top_anime(20) # Import 20 pages = ~500 anime

    puts "Successfully imported #{imported_count} anime!"
    puts "Total anime in database: #{Anime.count}"
  end

  desc "Import anime by popularity"
  task import_popular: :environment do
    puts "Starting popular anime import..."

    imported_count = 0

    (1..50).each do |page|
      result = JikanApiService.get_all_anime_by_genre(nil, 25, page)

      result[:data].each do |anime_data|
        next if Anime.exists?(mal_id: anime_data['mal_id'])

        begin
          Anime.create_from_api_data(anime_data)
          imported_count += 1
          print "."
        rescue => e
          Rails.logger.error "Failed to create anime #{anime_data['title']}: #{e.message}"
        end
      end

      sleep(0.5) # Respect rate limits

      break unless result[:pagination]['has_next_page']
    end

    puts "\nSuccessfully imported #{imported_count} anime!"
    puts "Total anime in database: #{Anime.count}"
  end
end