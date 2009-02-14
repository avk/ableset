require 'digest/sha1'

class User < ActiveRecord::Base

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :skills, :dependent => :destroy

  has_many :invites_from_me, :foreign_key => 'user_id', :class_name => 'Friendship', :dependent => :destroy
  has_many :invites_out, :through => :invites_from_me, :source => :friend, :conditions => [ "approved = ?", false ]
  has_many :invites_to_me, :foreign_key => 'friend_id', :class_name => 'Friendship', :dependent => :destroy
  has_many :invites_in, :through => :invites_to_me, :source => :user, :conditions => [ "approved = ?", false ]

  validates_presence_of     :first_name
  validates_format_of       :first_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message
  validates_length_of       :first_name,     :maximum => 20
  
  validates_presence_of     :last_name
  validates_format_of       :last_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message
  validates_length_of       :last_name,     :maximum => 30

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation
  

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def full_name
    first_name + " " + last_name
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def friends
    User.find_by_sql(["SELECT users.* FROM users INNER JOIN friendships 
                       WHERE ((user_id = ? AND users.id = friend_id) 
                       OR (friend_id = ? AND users.id = user_id)) 
                       AND approved = ?;", self, self, true])
  end
  
  def invite(target)
    if self.invites_in.include? target
      Friendship.from_to(target, self).confirm
    elsif self.invites_out.include? target
      return
    else
      Friendship.create(:user => self, :friend => target, :approved => false)
    end
  end
  
  def accept_invite_from(source)
    if self.invites_in.include? source
      Friendship.from_to(source, self).confirm
    end
  end
  
  def reject_invite_from(source)
    if self.invites_in.include? source
      Friendship.from_to(source, self).reject
    end
  end
  
  def revoke_invite_to(target)
    if self.invites_out.include? target
      Friendship.from_to(self, target).revoke
    end
  end
  
  def remove_friend(friend)
    friendship = Friendship.from_to(self, friend)
    friendship ||= Friendship.from_to(friend, self)
    friendship.destroy
  end
  
  


end
