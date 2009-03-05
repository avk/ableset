require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  test 'should not accept blank queries' do
    get :search, :query => ''
    assert_response :success
    assert flash[:warning], "Please enter something to search for."
  end

  test 'should be able to search if logged in' do
    login_as :hubert
    get :search, :query => skills(:ruby).name
    assert_response :success
    assert assigns(:friend_skills), [skills(:ruby).user_id]
  end
  
  test 'should be able to search if logged out' do
    get :search, :query => skills(:ruby).name
    assert_response :success
    assert assigns(:others), [skills(:ruby).user_id]
  end

  test 'should support case insensitive searches' do
    get :search, :query => skills(:ruby).name.upcase
    assert_response :success
    assert assigns(:others), [skills(:ruby).user_id]
  end

end
