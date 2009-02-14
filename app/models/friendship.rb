class Friendship < ActiveRecord::Base

  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_uniqueness_of :user_id, :scope => :friend_id, :message => "can only request friendship once"
  
  def self.from_to(from, to)
    self.find_by_user_id_and_friend_id(from, to)
  end
  
  def confirm
    self.approved = true
    self.save!
  end
  
  alias reject destroy
  alias revoke destroy
  
  def validate
    if user_id == friend_id
      errors.add(:friend_id, "is invalid; you cannot be friends with yourself")
    end
  end
  
end
