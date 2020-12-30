class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @membership = Membership.find_by(title: params[:title])
    @user = current_user
    @subscription = Subscription.new
    authorize @subscription
  end

  def create
    @membership = Membership.find(params[:membership_id])
    @user = current_user
    @subscription = Subscription.new
    @subscription.user = current_user
    @subscription.membership = @membership
    # @subscription.credits = @membership.credits
    authorize @subscription
    if @subscription.save
      customer = create_stripe_customer(@user)
      @session = create_checkout_session(customer, @user)
      session[:token] = @user.session_token
      render :checkout
    else
      flash.now[:error] = @user.errors.full_messages
      render :memberships
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def create_stripe_customer(user)
    customer = Stripe::Customer.create(
      email: current_user.email,
      metadata: {
        selected_membership: @membership.title
      }
    )
    user.update!(stripe_customer_id: customer.id)
    customer
  end

  def create_checkout_session(customer, user)
    price = Stripe::Price.list(lookup_keys: [user.membership.title]).data.first

    Stripe::Checkout::Session.create({
      customer: current_user.stripe_customer_id,
      success_url: 'http://localhost:3000/memberships',
      cancel_url: 'http://localhost:3000/memberships',
      payment_method_types: ['card'],
      line_items: [{
        price: 'price_1HyeqcH6qDbw82kK298cKplg',
        quantity: 1,
      }],
      mode: 'subscription',
    })
  end
end
