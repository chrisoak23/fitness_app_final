class TrainersController < ApplicationController
  before_action :require_admin, except: [:index, :show]

  def new
    @trainer = Trainer.new
  end

  def index
    @trainers = Trainer.paginate(page: params[:page], per_page: 5)
  end

  def show
    @trainer = Trainer.find(params[:id])
    @users = @trainer.users.paginate(page: params[:page], per_page: 5)
  end

  def create
    @trainer = Trainer.new(trainer_params)
    if @trainer.save
      flash[:notice] = "Trainer was successfully created"
      redirect_to @trainer
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

  def trainer_params
    params.require(:trainer).permit(:name)
  end

  def require_admin
    unless logged_in? && current_user.admin?
      flash[:alert] = "Only admins can perform that action"
      redirect_to trainers_path
    end
  end

end