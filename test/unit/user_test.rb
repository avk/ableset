require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @hubert, @avk = users(:hubert), users(:arthur)
    @one, @two = users(:one), users(:two)
    @quentin, @aaron = users(:quentin), users(:aaron)
  end


  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:email => 'quentin2@example.com')
    assert_equal users(:quentin), User.authenticate('quentin2@example.com', 'monkey')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'monkey')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  
  
  ##### invite creation
  
  def test_inviting_yourself_as_a_friend
    @hubert.invite @hubert
    assert !(@hubert.invites_out(true).include? @hubert)
    assert !(@hubert.invites_in(true).include? @hubert)
    assert !(friends? @hubert, @hubert)
  end
  
  def test_inviting_an_existing_friend
    assert (friends? @hubert, @avk)
    @hubert.invite @avk
    assert !(@hubert.invites_out(true).include? @avk)
    assert !(@hubert.invites_in(true).include? @avk)
  end
  
  def test_inviting_someone_who_has_invited_you
    assert (@two.invites_out.include? @avk)
    @avk.invite @two
    assert (friends? @avk, @two)
  end
  
  def test_inviting_someone_you_have_no_previous_connection_to
    assert (no_relationship? @one, @hubert)
    @one.invite @hubert
    assert (@one.invites_out(true).include? @hubert)
    assert (@hubert.invites_in(true).include? @one)
  end
  
  def test_against_duplicate_invites
    assert (no_relationship? @one, @hubert)
    outgoing = @one.invites_out.size
    incoming = @hubert.invites_in.size
    @one.invite @hubert
    @one.invite @hubert
    assert_equal outgoing + 1, @one.invites_out(true).size
    assert_equal incoming + 1, @hubert.invites_in(true).size
  end
  
  ##### invite modification
  
  def test_invite_creation
    assert no_relationship?(users(:quentin), users(:aaron))
    users(:quentin).invite(users(:aaron))
    users(:quentin).reload
    assert users(:quentin).invites_out.include?(users(:aaron))
  end
  
  def test_inviting_yourself
    assert no_relationship?(users(:quentin), users(:quentin))
    users(:quentin).invite(users(:quentin))
    users(:quentin).reload
    assert !(users(:quentin).invites_out.include? users(:quentin))
  end
  
  def test_should_not_invite_twice
    assert no_relationship?(@quentin, @aaron)
    assert_difference "Friendship.count", 1 do
      @quentin.invite @aaron
      assert @quentin.reload.invites_out.include?(@aaron)
      @quentin.invite @aaron
      assert @quentin.reload.invites_out.include?(@aaron)
    end
  end
  
  
  def test_invite_acceptance
    assert (@two.invites_out.include? @avk)
    @avk.accept_invite_from(@two)
    assert (friends? @avk, @two)
  end
  
  def test_invite_rejection
    assert (@two.invites_out.include? @avk)
    @avk.reject_invite_from(@two)
    assert (no_relationship? @avk, @two)
  end
  
  def test_revoking_an_invite
    assert (@two.invites_out.include? @avk)
    @two.revoke_invite_to(@avk)
    assert (no_relationship? @two, @avk)
  end
  
  def test_invite_modification_from_nonexistant_invite
    assert (no_relationship? @one, @hubert)
    @one.accept_invite_from @hubert
    @one.reject_invite_from @hubert
    @hubert.revoke_invite_to @one
    assert (no_relationship? @one, @hubert)
  end  
    
  ##### friend modification
  
  def test_removing_a_friend
    ## from one direction    
    assert (friends? @two, @hubert)
    @two.remove_friend @hubert
    assert (no_relationship? @two, @hubert)
    
    ## from the other direction
    @hubert.invite @two
    @two.reload; @hubert.reload
    @two.accept_invite_from @hubert
    @two.reload; @hubert.reload
    assert (friends? @two, @hubert)
    @hubert.remove_friend @two
    @two.reload; @hubert.reload
    assert (no_relationship? @two, @hubert)
  end
  
  def test_removing_a_non_friend
    assert !(friends? @quentin, @aaron)
    assert_no_difference "Friendship.count" do
      @quentin.remove_friend @aaron
    end
  end
  
  # user skills
  
  def test_should_delete_skills_when_user_is_deleted
    assert_no_difference "Skill.count" do
      u = create_user
      ["Ruby", "Rails", "Python", "Django"].each do |skill_name|
        u.skills << Skill.new(:name => skill_name)
      end
      u.destroy
    end
  end
  
  

protected
  def create_user(options = {})
    record = User.new({ :first_name => 'Quire', :last_name => 'Es', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end
  
  def friends?(u1, u2)
    (u1.friends.include? u2) and (u2.friends.include? u1)
  end
  
  def invite_exists?(u1, u2)
    if (u1.invites_in(true).include? u2) or (u1.invites_out(true).include? u2)
      return true
    else
      return false
    end
  end
  
  def no_relationship?(u1, u2)
    if (friends? u1, u2) or (invite_exists? u1, u2)
      return false
    else
      return true
    end
  end

end
