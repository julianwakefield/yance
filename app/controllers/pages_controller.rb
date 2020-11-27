class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home

  end

  def search
  end

  def profile
    @user = current_user
    @user_bookings = current_user.class_bookings
  end

end
