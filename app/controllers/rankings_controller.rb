class RankingsController < ApplicationController
  before_action :require_user

  def index
    @rankings = current_user.rankings.includes(:anime)

    # Default: sort by highest score
    @rankings = @rankings.order(score: :desc)

    # If user selects "Newest First"
    if params[:sort] == "newest"
      @rankings = @rankings.order(created_at: :desc)
    end
  end

  def new
    @animes = Anime.all.order(:title)
    @ranking = current_user.rankings.new
  end

  def create
    @ranking = current_user.rankings.new(ranking_params)

    if @ranking.save
      flash[:success] = "Anime ranked successfully!"
      redirect_to rankings_path
    else
      @animes = Anime.all.order(:title)
      render :new
    end
  end

  def edit
    @ranking = current_user.rankings.find(params[:id])
    @animes = Anime.all.order(:title)
  end

  def update
    @ranking = current_user.rankings.find(params[:id])

    if @ranking.update(ranking_params)
      flash[:success] = "Ranking updated successfully!"
      redirect_to rankings_path
    else
      @animes = Anime.all.order(:title)
      render :edit
    end
  end

  def destroy
    @ranking = current_user.rankings.find(params[:id])
    if @ranking.destroy
      flash[:success] = "Ranking deleted."
    else
      flash[:error] = "Failed to delete ranking."
    end
    redirect_to rankings_path
  end

  private

  def ranking_params
    params.require(:ranking).permit(:anime_id, :score, :comment)
  end
end