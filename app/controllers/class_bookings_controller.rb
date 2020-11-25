class ClassBookingsController < ApplicationController
  before_action :authenticate_user!

  def new
    @sportsclass = SportsClass.find(params[:sportsclass_id])
    @classbooking = ClassBooking.new
    authorize @classbooking
  end

  def create
    @sports_class = SportsClass.find(params[:sports_class_id])
    @classbooking = ClassBooking.new
    @classbooking.user = current_user
    @classbooking.sports_class = @sports_class
    if @classbooking.save
      redirect_to sports_classes_path, notice: "You booked your class"
    end
    authorize @classbooking
  end

  def destroy
    @classbooking = ClassBooking.find(params[:id])
    @classbooking.destroy
    redirect_to sports_classes_path
    authorize @classbooking
  end
end
