class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :require_user, only: [:edit, :update]
  before_action :require_same_user, only: [:edit, :update, :destroy]

  def show
    if current_user != @user && !current_user.admin?
      flash[:alert] = "You can only view your own profile"
      redirect_to current_user
    else
      @goals = @user.goals.paginate(page: params[:page], per_page: 5)
    end
  end

  def index
    if current_user.admin?
      @users = User.paginate(page: params[:page], per_page: 5)
    else
      flash[:alert] = "You do not have permission to view this page"
      redirect_to current_user
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "Your account information was successfully updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "#{@user.username} was created successfully. Welcome to the Fitness App!"
      redirect_to goals_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    session[:user_id] = nil if @user == current_user
    flash[:notice] = "Account and all associated goals successfully deleted"
    redirect_to root_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

  def require_same_user
    if current_user != @user && !current_user.admin?
      flash[:alert] = "You can only edit or delete your own account"
      redirect_to @user
    end
  end

end