class TrainersController < ApplicationController

  def new
    @trainer = Trainer.new
  end

  def index

  end

  def show

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

end