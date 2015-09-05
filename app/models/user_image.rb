class UserImage < ActiveRecord::Base
  belongs_to :user

  enum type: { avatar: 0, logo: 1 }
end
