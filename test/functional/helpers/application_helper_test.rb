require File.dirname(__FILE__) + '/../../test_helper'
require 'action_view/test_case'

class ApplicationHelperTest < ActionView::TestCase

  include AuthenticatedSystem

  def setup 
    @controller = SkillsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get :index
  end

  test "you? should be able to identify the current user" do
    @current_user = users(:arthur)
    assert !you?(users(:quentin))
    assert you? users(:arthur)
  end

  test "your_friend? should confirm if a user is a friend of the currently logged in user" do
    @current_user = users(:arthur)
    assert your_friend?(users(:hubert))
  end
  
  test "your_friend? should confirm if a user isn't a friend of the currently logged in user" do
    @current_user = users(:arthur)
    assert !your_friend?(users(:quentin))
  end
  
  test "your_friend? should return false if no one is logged in" do
    @current_user = false
    assert !your_friend?(users(:hubert))
  end

  test "linked_in_profile_widget should display a link if user has a LinkedIn profile" do
    avk = users(:arthur)
    expected = /<a class=["|']linkedin-profileinsider-popup["|'] href=["|'](http:\/\/www\.linkedin\.com\/.*)["|']>.*<\/a>/
    generated = linked_in_profile_widget(avk)
    assert generated.match(expected), "generated: #{generated} does not match expected: #{expected}"
    assert $1 == avk.linked_in_public_profile
  end
  
  test "linked_in_profile_widget should not display a link if user doesn't have a LinkedIn profile" do
    avk = users(:quentin)
    generated = linked_in_profile_widget(avk)
    assert generated == ''
  end

end