# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def you?(user)
    user == current_user
  end
  
  def your_friend?(user)
    (logged_in?) ? current_user.friends.include?(user) : false
  end

  def linked_in_profile_widget(user)
    if profile = user.linked_in_public_profile
      "<a class='linkedin-profileinsider-popup' href='#{profile}'>I'm on LinkedIn</a><br /><br />"
    else
      ''
    end
  end
  

end
