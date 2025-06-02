# app/models/anime.rb
class Anime < ApplicationRecord
  validates :mal_id, presence: true, uniqueness: true
  validates :title, presence: true

  scope :top_rated, -> { where('score > ?', 8.0).order(score: :desc) }
  scope :completed, -> { where(status: 'Finished Airing') }
  scope :airing, -> { where(status: 'Currently Airing') }

  # In your Anime model
  def self.create_from_api_data(data)
    anime = find_or_initialize_by(mal_id: data['mal_id'])
    anime.assign_attributes(
      anilist_id: data['anilist_id'],
      title: data['title'],
      synopsis: data['synopsis'],
      episodes: data['episodes'],
      status: data['status'],
      score: data['score'],
      image_url: data.dig('images', 'jpg', 'image_url'),
      aired_from: parse_date(data.dig('aired', 'from')),
      aired_to: parse_date(data.dig('aired', 'to')),
      genres: data['genres']
    )
    anime.save!
    anime
  end

  private

  def self.extract_genres(genres_array)
    return [] unless genres_array.is_a?(Array)
    genres_array.map { |genre| genre['name'] }.compact
  end

  def self.parse_date(date_string)
    return nil if date_string.blank?
    DateTime.parse(date_string)
  rescue
    nil
  end

  def self.find_or_create_from_api(mal_id)
    anime = find_by(mal_id: mal_id)
    return anime if anime

    api_data = JikanApiService.get_anime(mal_id)
    return nil unless api_data

    create_from_api_data(api_data)
  end
end