# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def you?
    @user == current_user
  end
  
  def your_friend?
    current_user.friends.include? @user
  end

  def linked_in_profile_widget(user)
    profile = user.linked_in_public_profile
    if profile
      "<a class='linkedin-profileinsider-popup' href='#{profile}'>I'm on LinkedIn</a><br /><br />"
    end
  end
  

end
