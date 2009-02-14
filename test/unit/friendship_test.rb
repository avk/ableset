require File.dirname(__FILE__) + '/../test_helper'

class FriendshipTest < ActiveSupport::TestCase

  def setup # code to be run before all tests
    @one, @two = users(:one), users(:two)
    @hubert = users(:hubert)
    @arthur = users(:arthur)
  end
  
  def test_user_friends_relation
    assert !@two.friends.empty?, "a user did not have any friends"
    assert_equal 2, @two.friends.size, "a user did not have the right amount of friends"
  end
  
  def test_user_invites_out_relation
    assert !@two.invites_out.empty?, "a user did not have any invites out"
    assert_equal 1, @two.invites_out.size, "a user did not have the right amount of outgoing invites"
  end
  
  def test_user_invites_in_relation
    assert @two.invites_in.empty?, "a user had some incoming invites when they weren't supposed to"
    assert @arthur.invites_in.size == 1
  end
  
  def test_no_self_referencing_friendships
    friendship = Friendship.new(:user => @one, :friend => @one)
    assert !friendship.valid?
  end
  
  def test_confirming_friendship_invite
    friendship = Friendship.find_by_user_id_and_friend_id(@two, @arthur)
    friendship.confirm
    assert (@two.friends.include? @arthur)
    assert (@arthur.friends.include? @two)
  end
  
  def test_rejecting_friendship_invite
    friendship = Friendship.find_by_user_id_and_friend_id(@two, @arthur)
    friendship.reject
    assert_nil Friendship.find_by_user_id_and_friend_id(@two, @arthur)
  end
  
  def test_revoking_friendship_invite
    friendship = Friendship.find_by_user_id_and_friend_id(@two, @hubert)
    friendship.revoke
    assert_nil Friendship.find_by_user_id_and_friend_id(@two, @hubert)
  end
      
end
