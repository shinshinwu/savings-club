class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups

  def rounds_remaining
    rounds_remaining = 0
    self.users.each do |user|
      rounds_remaining += 1 if user.paid?(self.id) == true
    end
    rounds_remaining
  end

end
