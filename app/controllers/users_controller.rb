class UsersController < ApplicationController
  def index
    @users = User.all.order last_login: :desc

    render json: @users
  end
end
