class GamesController < ApplicationController
  def index
    @games = Game.includes(:versions)

    render json: @games
  end
end
