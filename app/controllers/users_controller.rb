require "nexmos"
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]

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

#     client = ::Nexmos::Message.new(key:'ec19c1ba', secret: 'ba674a8a')
# # get result from Nexmo
# res = client.send_message(from: 'Ruby', to: '14014972054', text: 'Payment Confirmed')
# # check if send is success
# if res.success?
#   puts "ok"
# else
#   puts "fail"
# end
nexmo = Nexmo::Client.new(key:'ec19c1ba', secret: 'ba674a8a')

response = nexmo.send_message({
  from: '12529178633',
  to: '14014972654',
  text: 'Transaction completed'
})

if response.success?
  puts "Sent message: #{response.message_id}"
elsif response.failure?
  raise response.error
end


  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :account_name, :account_number)
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