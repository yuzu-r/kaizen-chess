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

  def getActivePlayer
    @game = Game.find(params[:id])
    render json: @game.active_player_id
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
    @game.update_attributes(active_player: @game.white_player)
    @game.update_attributes(status: 'active');
    if request.xhr?
      render :json => {:location => url_for(:controller => 'games', :action => 'show', id: @game)}
    else
      redirect_to game_path(@game)
    end

  end

  def status
    @game = Game.find(params[:id])
    if @game.pieces.present?
      @is_in_check = @game.is_in_check?(@game.black_player) ||  @game.is_in_check?(@game.white_player) 
      if @is_in_check
        if @game.is_in_check?(@game.black_player)
          @current_player_in_check = @game.black_player.email
          @current_color_in_check = "Black"
        else
          @current_player_in_check = @game.white_player.email
          @current_color_in_check = "White"
        end 
      end
    end
    render :json => { :success => "success", :status_code => "200", :is_in_check => @is_in_check, :current_player_in_check => @current_player_in_check, :current_color_in_check => @current_color_in_check }
  end


  private
    def game_params
      params.require(:game).permit(:name)
    end

end
