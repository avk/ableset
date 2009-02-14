class SearchController < ApplicationController

  # GET /search/:query
  def search
    @query = params[:query]
    @friend_skills, @group_skills, @location_skills = [], [], []
    
    if logged_in?
      matches =  Skill.find(:all, :conditions => 
        ["user_id != ? AND name LIKE ?", current_user.id, "%#{@query}%"], :include => [:user])
    
      friend_ids = current_user.friends.map(&:id)
      
      matches.each do |skill|
        @friend_skills << matches.delete(skill) if friend_ids.include? skill.user_id
        # @group_skills << matches.delete(skill) if group_ids.include? skill.user_id
        # @location_skills << matches.delete(skill) if skill.user.location == current_user.location
      end
      @others = matches
    else
      @others = Skill.find(:all, :conditions => ["name LIKE ?", "%#{@query}%"], :include => [:user])
    end
    
    respond_to do |wants|
      wants.html # search.html.erb
      # wants.js {
      #   render :update do |page|
      # 
      #   end
      # }
    end
  end
  
  # GET /search/person/:id
  def person
    @user = User.find(params[:new_team_user_id], :include => :skills)
    @skills = @user.skills
    existing_skills = Skill.find(:all, :conditions => { :id => params[:existing_skills] })
    @team_size = params[:team_size].to_i + 1
    
    respond_to do |wants|
      wants.js { 
        render :update do |page|
          existing_skills.each do |skill|
            insert = (@skills.map(&:name).include? skill.name) ? "<td><div style='width:43px; margin: 0 auto;'>#{image_tag 'checkmark.png'}</div></td>" : '<td></td>'
            page.insert_html :after, "team_skill_id_#{skill.id}", insert
          end
          
          page.insert_html :after, :team_person_search, "<th>#{link_to h(@user.full_name), user_skills_path(@user)}</th>"
          new_skills = @skills.clone.delete_if { |s| existing_skills.map(&:name).include? s.name }
          new_skills.each do |skill|
            page.insert_html :before, :team_skill_search, :partial => 'col', :locals => {:skill => skill}
          end
          
          page << "$('team_size').value = #{@team_size};"
        end
      }
    end
  end
  


end
