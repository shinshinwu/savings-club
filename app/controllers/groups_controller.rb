class GroupsController < ApplicationController
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      flash[:success] = "New Group #{@group.name} created!"
      render 'add_members'
    else
      render 'new'
    end
  end

  def add_members
    @group = Group.find(params[:id])

  end

  def show
  end

  private

  def group_params
    params.require(:group).permit(:name, :group_type, :payment_date, :payment_amount)
  end

  def member_params

  end
end
