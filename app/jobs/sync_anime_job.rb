# app/jobs/sync_anime_job.rb
class SyncAnimeJob < ApplicationJob
  queue_as :default

  def perform
    Anime.sync_with_jikan
  end
end