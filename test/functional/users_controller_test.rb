require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase

  def test_should_allow_new_user_form
    get :new
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  
  def test_should_render_generic_home_page
    get :home
    assert_template 'generic_home'
  end
  
  def test_should_render_logged_in_home_page
    login_as :quentin
    get :home
    assert_template 'home'
  end
  
  def test_should_list_users_friends
    login_as :arthur
    get :friends, :user_id => users(:arthur).id
    assert_response :success
    assert assigns(:friends), users(:arthur).friends
  end
  
  def test_should_allow_users_to_invite_other_users_to_be_friends
    assert_difference "Friendship.count", 1 do
      login_as :quentin
      post :invite, :user_id => users(:quentin).id, :id => users(:aaron).id
      assert_redirected_to home_user_path(users(:quentin))
    end
  end
  
  def test_should_allow_users_to_accept_invites_from_other_users
    users(:quentin).invite users(:aaron)
    login_as :aaron
    put :accept, :user_id => users(:aaron).id, :id => users(:quentin).id
    assert_redirected_to home_user_path(users(:aaron))
    assert users(:aaron).friends.include? users(:quentin)
  end
  
  def test_should_allow_users_to_reject_invites_from_other_users
    users(:quentin).invite users(:aaron)
    assert_difference "Friendship.count", -1 do
      login_as :aaron
      put :reject, :user_id => users(:aaron).id, :id => users(:quentin).id
      assert_redirected_to home_user_path(users(:aaron))
      assert !(users(:aaron).friends.include? users(:quentin))
    end
  end
  
  def test_should_allow_users_to_revoke_invites_to_other_users
    users(:quentin).invite users(:aaron)
    assert_difference "Friendship.count", -1 do
      login_as :quentin
      put :revoke, :user_id => users(:quentin).id, :id => users(:aaron).id
      assert_redirected_to home_user_path(users(:quentin))
      assert !(users(:quentin).invites_out.include? users(:aaron))
    end
  end
  
  def test_should_allow_one_user_to_unfriend_another
    assert_difference "Friendship.count", -1 do
      login_as :arthur
      delete :unfriend, :user_id => users(:arthur).id, :id => users(:hubert).id
      assert_redirected_to home_user_path(users(:arthur))
      assert !(users(:arthur).friends.include? users(:hubert))
    end
  end
  

protected
  def create_user(options = {})
    post :create, :user => { :first_name => 'Quire', :last_name => 'Es', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end
