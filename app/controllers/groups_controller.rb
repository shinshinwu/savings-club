class GroupsController < ApplicationController
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      @group.update(disbursement_date: @group.payment_date + 25)
      render 'new_members'
    else
      render 'new'
    end
  end

# GET request to the form page to add new members to the group
  def new_members
    @group = Group.find(params[:id])
  end

# POST request to add the members to the group
  def add_members
    @group = Group.find(params[:id])
    params.keys.each do |key|
      if key.include?('member')
        p "I got called"
        p params[key]
        UserGroup.create(group_id: @group.id, user_id: User.find_by(email: params[key]).id, paid: false)
      end
    end
    @group.update(disbursement_amount: @group.users.count * @group.payment_amount)
    redirect_to @group
  end

  def show
    @group = Group.find(params[:id])
  end

  private

  def group_params
    params.require(:group).permit(:name, :group_type, :payment_date, :payment_amount, :member1, :member2, :member3, :member4, :member5, :member6, :member7, :member8, :member9, :member10, :member11, :member12,)
  end

end
