class SearchController < ApplicationController

  # GET /search/:query
  def search
    @query = params[:query]
    matches =  Skill.find(:all, :conditions => 
      ["user_id != ? AND name LIKE ?", current_user.id, "%#{@query}%"], :include => [:user])
    
    friend_ids = current_user.friends.map(&:id)
    @friend_skills, @group_skills, @location_skills = [], [], []
    
    matches.each do |skill|
      @friend_skills << matches.delete(skill) if friend_ids.include? skill.user_id
      # @group_skills << matches.delete(skill) if group_ids.include? skill.user_id
      # @location_skills << matches.delete(skill) if skill.user.location == current_user.location
    end
    
    @others = matches
  end
  

end
