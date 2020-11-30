require "date"
require 'uri'
require 'net/http'
require 'openssl'
require 'json'


class SportsClassesController < ApplicationController
  before_action :set_sports_class, only: [:show, :edit, :update, :destroy]

  def index
    @sports_classes = policy_scope(SportsClass).order(date_time: :asc)
    handle_search
    handle_date_search
    handle_filter_cards
    @classbooking = ClassBooking.new
    @classbookings = policy_scope(ClassBooking).where(user: current_user)
  end
  def show


  end
  def new
    @trainer = Trainer.find(params[:trainer_id])
    @trainer.user = current_user
    @sportsclass = SportsClass.new
    authorize @sportsclass
    # authorize @trainer, policy_class: SportsClassPolicy
  end
  def create
    @trainer = Trainer.find(params[:trainer_id])
    @sportsclass = SportsClass.new(sports_class_params)
    @sportsclass.trainer = @trainer
    authorize @sportsclass
    if @sportsclass.save
      room = create_room(@sportsclass)
      @sportsclass.update(room: JSON.parse(room.body)["name"])
      redirect_to sports_classes_path, notice: "Your class has been created"
    else
      render :new
    end
  end
  def edit
    authorize @sportsclass
  end
  def update
    authorize @sportsclass
    if @sportsclass.update(sports_class_params)
      redirect_to sports_classes_path, notice: "Your class has been updated"
    else
      render :edit
    end
  end
  def destroy
    # authorize @sportsclass
    @sportsclass.destroy
    redirect_to sports_classes_path, notice: "#{@sportsclass.title} has been deleted"
  end
  private

  def create_room(sportsclass)
    url = URI("https://api.daily.co/v1/rooms")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = 'application/json'
    request["Authorization"] = 'Bearer ' + ENV["DAILY"]
    request.body = "{\"name\":\"#{sportsclass.id}\",\"privacy\":\"public\"}"

    response = http.request(request)
    return response
  end
  def set_sports_class
    @sportsclass = SportsClass.find(params[:id])
    authorize @sportsclass
  end
  def sports_class_params
    params.require(:sports_class).permit(:title, :description, :date_time, :duration, :category, :difficulty_level, :sweat_level, :experience_level, :equipment, :language, :photo)
  end
  def handle_search
    if params[:query].present?
      @sports_classes = @sports_classes.search(params[:query])
    end
  end
  def handle_date_search
    if params[:starts_at].present?
      @sports_classes = SportsClass.where(date_time: Range.new(*params[:starts_at].split(" to ")))
    end
  end

  def handle_filter_cards
    if params[:query].present?
      @sports_classes = SportsClass.where(category: params[:category])
    end
  end
end
