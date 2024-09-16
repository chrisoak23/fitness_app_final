class GoalsController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def show
  end

  def index
    @goals = Goal.all
  end

  def new
    @goal = Goal.new
  end

  def edit
  end

  def create
    @goal = Goal.new(article_params)
    @goal.user = User.first
    if @goal.save
      flash[:notice] = "Goal was created successfully."
      redirect_to @goal
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    if @goal.update(article_params)
      flash[:notice] = "Goal was updated successfully."
      redirect_to @goal
    else
      render 'edit'
    end
  end

  def destroy
    @goal.destroy
    redirect_to goals_path
  end

  private

  def set_article
    @goal = Goal.find(params[:id])
  end

  def article_params
    params.require(:goal).permit(:name, :sport)
  end

end