class GamesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :open]
  attr_reader :active_game_count, :pending_game_count

  def new
    @game = Game.new
  end

  def index
    @games = Game.all
    if @games.empty?
      @active_game_count = 0
      @pending_game_count = 0
    else
      @active_game_count = Game.first.active_game_count
      @pending_game_count = Game.first.pending_game_count
    end
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

  def firebase_info
    @game = Game.find(params[:id])
    render json: {:success => "success", :status_code => "200", 
        :config => {:apiKey => ENV["firebase_api_key"], 
                    :authDomain => ENV["firebase_auth_domain"],
                    :databaseURL => ENV["firebase_database_url"],
                    :storageBucket => ENV["firebase_storage_bucket"]
                    }
                  }
  end

  def create
    @game = current_user.games_as_white.create(game_params)
    if @game.valid?
      @game.initialize_firebase
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
    @game.update_attributes(status: 'active')
    @game.join_firebase
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
        @is_in_checkmate = @game.is_in_checkmate?(@game.black_player) || @game.is_in_checkmate?(@game.white_player)
        if @is_in_checkmate
          if @game.is_in_checkmate?(@game.black_player)
            @player_in_checkmate = @game.black_player.email
            @color_in_checkmate = "Black"
            @game.update_attributes(winning_player: @game.white_player_id, losing_player: @game.black_player_id, status: "finished")
            @game.checkmated_firebase(@game.black_player.id)
          else
            @player_in_checkmate = @game.white_player.email
            @color_in_checkmate = "White"
            @game.update_attributes(winning_player: @game.black_player_id, losing_player: @game.white_player_id, status: "finished")
            @game.checkmated_firebase(@game.white_player.id)
          end
        else
          if @game.is_in_check?(@game.black_player)
            @current_player_in_check = @game.black_player.email
            @current_color_in_check = "Black"
            @game.in_check_firebase(@game.black_player)
          else
            @current_player_in_check = @game.white_player.email
            @current_color_in_check = "White"
            @game.in_check_firebase(@game.white_player)
          end 
        end
      else
        @game.in_check_firebase()
      end
    end
    render :json => { :success => "success", :status_code => "200", :is_in_check => @is_in_check, 
      :current_player_in_check => @current_player_in_check, :current_color_in_check => @current_color_in_check, 
      :is_in_checkmate => @is_in_checkmate, :player_in_checkmate => @player_in_checkmate, :color_in_checkmate => @color_in_checkmate }
  end

  def forfeit
    @game = Game.find(params[:id])
    if @game.active_player.id == @game.white_player_id
      @game.update_attributes(winning_player: @game.black_player_id, losing_player: @game.white_player_id, status: "finished")
      @game.forfeit_firebase(@game.white_player_id)
    else
      @game.update_attributes(winning_player: @game.white_player_id, losing_player: @game.black_player_id, status: "finished")
      @game.forfeit_firebase(@game.black_player_id)
    end

    if request.xhr?
      render :json => {:location => url_for(:controller => 'games', :action => 'show', id:@game)}
    else
      redirect_to game_path(@game)
    end
  end

  private
    def game_params
      params.require(:game).permit(:name)
    end

end
