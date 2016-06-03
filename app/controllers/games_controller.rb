class GamesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  def new
    @game = Game.new
  end

  def index
    @games = Game.all
  end

  def create
    @game = current_user.games.create(game_params)
    if @game.valid?
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def game_params
      params.require(:game).permit(:name)
    end

end
