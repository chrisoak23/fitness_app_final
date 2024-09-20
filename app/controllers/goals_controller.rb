class GoalsController < ApplicationController
  before_action :set_goal, only: [:show, :edit, :update, :destroy]

  def show
  end

  def index
    @goals = Goal.paginate(page: params[:page], per_page: 5)
  end

  def new
    @goal = Goal.new
  end

  def edit
  end

  def create
    @goal = Goal.new(goal_params)
    @goal.user = User.first
    if @goal.save
      flash[:notice] = "Goal was created successfully."
      redirect_to @goal
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    if @goal.update(goal_params)
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

  def set_goal
    @goal = Goal.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit(:name, :sport)
  end

end