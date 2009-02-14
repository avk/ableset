# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def you?
    @user == current_user
  end
  
  def your_friend?
    current_user.friends.include? @user
  end
  

end
