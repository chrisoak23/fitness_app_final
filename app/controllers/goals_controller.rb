class GoalsController < ApplicationController
  def show
    @goal = Goal.find(params[:id])
  end

  def index
    @goals = Goal.all
  end

  def new

  end

  def create
    @goal = Goal.new(params.require(:goal).permit(:name, :sport))
    @goal.save
    redirect_to @goal
  end

end