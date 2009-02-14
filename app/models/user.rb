require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :skills, :dependent => :destroy

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

end
