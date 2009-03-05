require 'test_helper'

class SkillTest < ActiveSupport::TestCase

  test 'should create a skill' do
    assert_difference "Skill.count", 1 do
      skill = create_skill
      assert !skill.new_record?, "#{skill.errors.full_messages.to_sentence}"
    end
  end

  test 'should require a name' do
    assert_no_difference "Skill.count" do
      skill = create_skill(:name => nil)
      assert skill.errors.on(:name)
    end
  end
  
  test 'should require unique names per user' do
    assert_no_difference "Skill.count" do
      skill = create_skill(:name => skills(:ruby).name, :user_id => skills(:ruby).user_id)
      assert skill.errors.on(:name)
    end
  end
  
  test 'should judge if case-insensitive names are unique per user' do
    duplicate = 'Jython on Grails'
    assert_difference "Skill.count", 1 do
      skill = create_skill(:name => duplicate)
      assert !skill.new_record?, "#{skill.errors.full_messages.to_sentence}"
      skill = create_skill(:name => duplicate.upcase)
      assert skill.errors.on(:name)
    end
  end
  
  test 'should require a user' do
    assert_no_difference "Skill.count" do
      skill = create_skill(:user => nil)
      assert skill.errors.on(:user_id)
    end
  end
  
  test 'should require a valid user' do
    assert_no_difference "Skill.count" do
      skill = create_skill(:user => User.new)
      assert skill.errors.on(:user)
    end
  end

  test 'should not accept invalid LinkedIn public profile URLs' do
    ["http://www.linkedout.com", "asbdfasdf", "www.facebook.com"].each do |url|
      raised = false
      begin
        Skill.from_linked_in_profile(url)
      rescue ArgumentError
        raised = true
      end
      assert raised
    end
  end

  test 'should accept valid LinkedIn public profile URLs' do
    # Arthur, Alex
    ['http://www.linkedin.com/in/arthurk', 'http://www.linkedin.com/pub/7/a1/112'].each do |url|
      not_raised = true
      begin
        Skill.from_linked_in_profile(url)
      rescue ArgumentError
        not_raised = false
      end
      assert not_raised
    end
  end
  
  test 'should import specialties from LinkedIn public profiles' do
    # Alex Bain has the following specialities (and no interests) as of 3/2/09
    specialties = "(X)HTML, CSS, Javascript, YUI, Ruby on Rails, usability, Template Toolkit".split(', ')
    imported = Skill.from_linked_in_profile('http://www.linkedin.com/pub/7/a1/112')
    assert specialties == imported, "\nassumed: #{specialties.inspect}\nactual: #{imported.inspect}"
  end
  
  test 'should import interests from LinkedIn public profiles' do
    # Stephen Wong has the following interests (and no specialities) as of 3/2/09
    interests = "marathon running, snowboarding, philosophy and religion".split(', ')
    imported = Skill.from_linked_in_profile('http://www.linkedin.com/in/swong')
    assert interests == imported, "\nassumed: #{interests.inspect}\nactual: #{imported.inspect}"
  end

  test 'should import specialties and interests from LinkedIn public profiles' do
    # Jimmy Nguyen has the following specialities and interests as of 3/2/09
    specialties = "Multimedia, Web Applications".split(', ')
    interests = "Multimedia, Sports, Dance, Music".split(', ')
    
    imported = Skill.from_linked_in_profile('http://www.linkedin.com/in/jimmyn')
    all = specialties | interests
    assert all == imported, "\nassumed: #{interests.inspect}\nactual: #{all.inspect}"
  end

end
