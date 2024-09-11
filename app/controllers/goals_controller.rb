class GoalsController < ApplicationController
  def show
    @goal = Goal.find(params[:id])
  end

  def index
    @goals = Goal.all
  end

end