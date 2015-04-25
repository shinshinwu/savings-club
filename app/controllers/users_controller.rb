require 'dotenv'
require 'httparty'
require 'dwolla'
require 'uri'

class UsersController < ApplicationController
  # before_action :logged_in_user, only: [:edit, :update]
  # before_action :correct_user, only: [:edit, :update]

  def index
    #greeting page
  end

  def show
    #user profile page that shows questions
    @user = User.find(params[:id])
    @last_contribution_group = Group.find(@user.last_contribution.group_id)
    @last_disbursement_group = Group.find(@user.last_disbursement.group_id)
    @credit = @user.groups.where(group_type: "Credit")
    @savings = @user.groups.where(group_type: "Savings")
    @rando_interest_rate = rand(4..12)
  end

  def new
    #sign up form
    @user = User.new
  end

  def edit
    # update password/username form?
    @user = User.find(params[:id])
  end

  def create
    # create new user in database
    @user = User.new(user_params)
    if @user.save
      log_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
    # update password or username?
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    # delete user
    User.find(params[:id]).destroy
    redirect_to users_url
  end

  def make_payment
    # update user payment amount
    @user = User.find(params[:id])
    p params
    p params[:group]
    @group = Group.find(params[:group])
    @user.total_contribution += @group.payment_amount
    # update transaction
    Transaction.create(user_id: @user.id, group_id: @group.id, transaction_type: "debit", transaction_amount: @group.payment_amount)

    redirect_to @user
  end

  def oauth
    # need to check if user has connected dowalla already
    user = current_user
    Dwolla::api_key = ENV['DWOLLA_KEY']
    Dwolla::api_secret = ENV['DWOLLA_SECRET']
    Dwolla::sandbox = true
    if user.dwolla_token.nil?
      redirect_uri = "http://localhost:3000/users/#{user.id}/callback"
      # redirect_to "https://www.dwolla.com/oauth/v2/authenticate?client_id=#{client_id}&response_type=code&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fusers%2F#{user.id}%2Fcallback&scope=send|transactions"

      # https://www.dwolla.com/oauth/v2/authenticate?client_id=NqVSIQ%2Btw3D8Qtl8dHbXuCTN8KM%2BlLJOSCUEwDvZigvlr3r13R&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fusers%2F8%2Fcallback&response_type=code&scope=send%7Ctransactions%7Cbalance%7Crequest%7Ccontacts%7Caccountinfofull%7Cfunding
      authUrl = Dwolla::OAuth.get_auth_url(redirect_uri)
      p URI.unescape(authUrl)
      redirect_to authUrl
    else
      redirect_to user
    end
  end

  def callback
    user = current_user
    authorization_code = params['code']
    redirect_uri = "http://localhost:3000/users/#{user.id}/callback"
    Dwolla::api_key = ENV['DWOLLA_KEY']
    Dwolla::api_secret = ENV['DWOLLA_SECRET']
    # Dwolla::token = HTTParty.post("https://www.dwolla.com/oauth/v2/token/client_id=#{client_id}&client_secret=#{client_secret}&code=#{authorization_code}&grant_type=authorization_code&redirect_uri=localhost%3A3000%2Fusers%2F#{user.id}%2Fcallback")
    token_response = Dwolla::OAuth.get_token(authorization_code, redirect_uri)
    dwolla_token = token_response["access_token"]
    dwolla_refresh_token = token_response["refresh_token"]
    user.dwolla_token = dwolla_token
    user.dwolla_refresh_token = dwolla_refresh_token
    user.save

    redirect_to user
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_digest, :account_name, :account_balance, :account_number, :total_contribution, :total_received)
  end

  def logged_in_user
    unless logged_in?
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end