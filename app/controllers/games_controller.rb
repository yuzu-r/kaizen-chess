class GamesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :open]
  def new
    @game = Game.new
  end

  def index
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id])
  end

  def getPieces
    @pieces = Game.find(params[:id]).pieces
    render json: @pieces
  end

  def create
    @game = current_user.games_as_white.create(game_params)
    if @game.valid?
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def open
    @games = Game.all
  end

  def join
    @game = Game.find(params[:id])
    @game.update_attributes(black_player: current_user)
    @game.setup
    redirect_to game_path(@game)
  end


  private
    def game_params
      params.require(:game).permit(:name)
    end

end
