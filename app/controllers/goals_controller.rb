class GoalsController < ApplicationController
  before_action :set_goal, only: [:show, :edit, :update, :destroy]
  before_action :require_user, except: [:show, :index]
  before_action :require_same_user, only: [:edit, :update, :destroy]

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
    @goal.user = current_user
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

  def require_same_user
    if current_user != @goal.user
      flash[:alert] = "You can only edit or delete your own goal"
      redirect_to @goal
    end
  end

end