require 'test_helper'
require 'my_enumerable'

class SkillsControllerTest < ActionController::TestCase

  def setup
    @user = users(:quentin)
    @name = @user.first_name.downcase
  end

  test "should get list of skills" do
    get :index, :user_id => @user.id
    assert_response :success
    assert_not_nil assigns(:skills)
    assert assigns(:skills), @user.skills
  end

  test "should show skill" do
    get :show, :id => @user.skills.first.id, :user_id => @user.id
    assert_response :success
  end
  
  test "should not be able to add new skills if not logged in" do
    get :new, :user_id => @user.id
    assert_redirected_to new_session_path
  end

  test "should be able to add new skills if logged in" do
    login_as @name
    get :new, :user_id => @user.id
    assert_response :success
  end

  test "should not create skill if not logged in" do
    assert_no_difference('Skill.count') do
      post :create, :skills => 'Perl', :user_id => @user.id
    end

    assert_redirected_to new_session_path
  end

  test "should create skill only if logged in" do
    login_as @name
    assert_difference('Skill.count') do
      post :create, :skills => 'Perl', :user_id => @user.id
    end

    assert_redirected_to user_skills_path(@user)
  end
  
  test "should be able to create multiple skills from a comma-separated list" do
    login_as @name
    skills = ['drawing', 'painting', 'graphic design', 'chatting it up at the art murmur']
    assert_difference "Skill.count", skills.size do
      post :create, :skills => skills.join(', '), :user_id => @user.id
    end
    
    assert_redirected_to user_skills_path(@user)
    assert flash[:notice].match(Regexp.new(skills.join(', ')))
  end
  
  test "should create only valid skills if given a mix of new valid and invalid skills" do
    login_as @name
    skills = ['drawing', 'drawing', 'painting', 'visual design']
    assert_difference "Skill.count", skills.uniq.size do
      post :create, :skills => skills.join(', '), :user_id => @user.id
    end
    
    assert_redirected_to user_skills_path(@user)
    assert flash[:notice].match(Regexp.new(skills.uniq.join(', ')))
    assert flash[:warning].match(Regexp.new(skills.dups.join(', ')))
  end
  
  test "should redirect back to new if not able to create any new skills" do
    login_as @name
    duplicates = %w(Jython Nylon Neptune Skyler)
    assert_difference "Skill.count", duplicates.size do
      duplicates.each do |dup|
        create_skill(:name => dup, :user => @user)
      end
      post :create, :skills => duplicates.join(', '), :user_id => @user.id
    end
    assert_template 'new'
    assert flash[:error].match(Regexp.new(duplicates.join(', ')))
    assert assigns(:unsaved_skills) == duplicates
  end

  test "should not be able to edit skills if not logged in" do
    get :edit, :id => @user.skills.first.id, :user_id => @user.id
    assert_redirected_to new_session_path
  end
  
  test "should edit skills only if logged in" do
    login_as @name
    get :edit, :id => @user.skills.first.id, :user_id => @user.id
    assert_response :success
  end
  
  test "should not be able to update skills if not logged in" do
    skill = @user.skills.first
    old_name = skill.name
    
    put :update, :id => skill.id, :user_id => @user.id, :skill => {:name => 'JSON'}
    assert_redirected_to new_session_path
    
    skill.reload
    assert skill.name == old_name
  end
  
  test "should update skills only if logged in" do
    skill = @user.skills.first
    new_name = "JSON"
    
    login_as @name
    put :update, :id => skill.id, :user_id => @user.id, :skill => {:name => new_name}
    assert_redirected_to user_skills_path(@user)
    
    skill.reload
    assert skill.name == new_name
  end
  
  test "should redirect back to edit if update failed" do
    login_as @name
    put :update, :id => @user.skills.first.id, :user_id => @user.id, :skill => {:name => ''}
    assert_template 'edit'
  end
  
  test "should not be able to destroy skills if not logged in" do
    assert_no_difference('Skill.count') do
      delete :destroy, :id => @user.skills.first.id, :user_id => @user
    end
    assert_redirected_to new_session_path
  end
  
  test "should destroy skills only if logged in" do
    login_as @name
    assert_difference "Skill.count", -1 do
      delete :destroy, :id => @user.skills.first.id, :user_id => @user
    end
    assert_redirected_to user_skills_path(@user)
  end
  
  test "should not be able to import skills from LinkedIn if not logged in" do
    profile = 'http://www.linkedin.com/in/arthurk'
    get :new_from_linked_in, :user_id => @user.id, :public_profile => profile
    assert_redirected_to new_session_path
  end
  
  test "should be able to import skills from LinkedIn only if logged in" do
    login_as @name
    profile = 'http://www.linkedin.com/in/arthurk'
    get :new_from_linked_in, :user_id => @user.id, :public_profile => profile
    assert_response :success
  end

  test "should gracefully deal with invalid URLs when importing skills from LinkedIn" do
    login_as @name
    urls = ['http://www.facebook.com/', 'bullshit', 'git://github.com/spicycode/rcov.git']
    assert_no_difference "Skill.count" do
      urls.each do |url|
        @request.env["HTTP_REFERER"] = ''
        post :new_from_linked_in, :user_id => @user.id, :public_profile => url
        assert flash[:error].match(Regexp.new(url))
      end
    end
  end
  
  test "should not be able to create skills from LinkedIn if not logged in" do
    skills = %w(construction building woodwork)
    assert_no_difference "Skill.count" do
      post :create_from_linked_in, :user_id => @user.id, :new_skills => skills
    end
    assert_redirected_to new_session_path
  end
  
  test "should be able to create skills from LinkedIn only if logged in" do
    skills = %w(construction building woodwork)
    assert_difference("Skill.count", skills.size) do
      login_as @name
      post :create_from_linked_in, :user_id => @user.id, :new_skills => skills
    end
    assert_redirected_to user_skills_path(@user)
  end
  
  test "should gracefully deal with invalid skills from LinkedIn" do
    # invalid meaning duplicate, blank, or other Skill model constraints
    valid_skills = ['lumberjacking', 'heroku']
    invalid_skills = ['', 'lumberjacking', nil]
    assert_difference("Skill.count", valid_skills.size) do
      login_as @name
      post :create_from_linked_in, :user_id => @user.id, :new_skills => (valid_skills + invalid_skills)
      
      assert flash[:notice].match( Regexp.new(valid_skills.join(', ')) ), "flash[:notice]: #{flash[:notice]} v. valid: #{valid_skills.join(', ')}"
      assert flash[:error].match( Regexp.new(invalid_skills.join(', ')) ), "flash[:error]: #{flash[:error]} v. invalid: #{invalid_skills.join(', ')}"
    end
  end
  
end
