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
    @subscription = current_user.subscription
    @membership = current_user.subscription.membership
    if current_user.subscription.subscription_status == "active" || "trialing"
      @classbooking.save
      redirect_to sports_classes_path, notice: "Your class is successfully booked!"
    elsif current_user.subscription.subscription_status == "incomplete"
      redirect_to sports_classes_path, notice: "Please subcribe to a membership."
    else
      redirect_to sports_classes_path, notice: "You have already booked this class"
    end
      authorize @classbooking
  end

  def destroy
    @classbooking = ClassBooking.find(params[:id])
    @membership = current_user.subscription.membership
    @subscription = current_user.subscription
    @classbooking.destroy
    redirect_to sports_classes_path
    authorize @classbooking
  end
end
