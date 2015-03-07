class User < ActiveRecord::Base
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :transactions

  # write user validations and password hash shit here
end
