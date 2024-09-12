class GoalsController < ApplicationController
  def show
    @goal = Goal.find(params[:id])
  end

  def index
    @goals = Goal.all
  end

  def new
    @goal = Goal.new
  end

  def edit
    @goal = Goal.find(params[:id])
  end

  def create
    @goal = Goal.new(params.require(:goal).permit(:name, :sport))
    if @goal.save
      flash[:notice] = "Goal was created successfully."
      redirect_to @goal
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    @goal = Goal.find(params[:id])
    if @goal.update(params.require(:goal).permit(:name, :sport))
      flash[:notice] = "Goal was updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy
    redirect_to goals_path
  end

end