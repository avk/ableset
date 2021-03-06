require 'open-uri'
require 'hpricot'

class SkillsController < ApplicationController
  
  before_filter :login_required, :except => [:index, :show]
  before_filter :get_user, :only => [:index, :show]
  
  # GET /users/1/skills
  # GET /users/1/skills.xml
  def index
    @skills = @user.skills

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @skills }
    end
  end

  # GET /users/1/skills/1
  # GET /users/1/skills/1.xml
  def show
    @skill = @user.skills.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @skill }
    end
  end

  # GET /users/1/skills/new
  # GET /users/1/skills/new.xml
  def new
    @unsaved_skills = []

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @skill }
    end
  end

  # GET /users/1/skills/1/edit
  def edit
    @skill = current_user.skills.find(params[:id])
  end

  # POST /users/1/skills
  # POST /users/1/skills.xml
  def create
    @saved_skills, @unsaved_skills = [], []
    Skill.parse(params[:skills]).each do |skill|
      s = Skill.new(:name => skill, :user => current_user)
      begin
        s.save!
        @saved_skills << skill
      rescue
        @unsaved_skills << skill
      end
    end

    respond_to do |format|
      if @saved_skills.size > 0
        flash[:notice] = "Skills successfully created: #{@saved_skills.join(', ')}"
        unless @unsaved_skills.empty?
          flash[:warning] = "Couldn't save the following skills: #{@unsaved_skills.join(', ')}"
        end
        format.html { redirect_to(user_skills_path(current_user)) }
        format.xml  { render :xml => @saved_skills, :status => :created }
      else
        flash[:error] = "Couldn't save the following skills: #{@unsaved_skills.join(', ')}"
        format.html { render :action => "new" }
        format.xml  { render :xml => @unsaved_skills, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1/skills/1
  # PUT /users/1/skills/1.xml
  def update
    @skill = current_user.skills.find(params[:id])

    respond_to do |format|
      if @skill.update_attributes(params[:skill])
        flash[:notice] = 'Skill was successfully updated.'
        format.html { redirect_to(user_skills_path(current_user)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @skill.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1/skills/1
  # DELETE /users/1/skills/1.xml
  def destroy
    @skill = current_user.skills.find(params[:id])
    @skill.destroy

    respond_to do |format|
      flash[:notice] = 'Skill deleted.'
      format.html { redirect_to(user_skills_path(current_user)) }
      format.xml  { head :ok }
    end
  end
  
  def new_from_linked_in    
    begin
      @public_profile = params[:public_profile]
      @skills = Skill.from_linked_in_profile(@public_profile)
    rescue ArgumentError => invalid_url
      flash[:error] = invalid_url.message + ": " + @public_profile
      redirect_to :back
    end
    
    # TODO:
    # if we can't grab any skills from the public profile:
    # - give them the option to log in to LinkedIn
    # - Mechanize to viewProfile page
    # - grab (doc/'.content .null') and (doc/'#interests')    
  end
  
  def create_from_linked_in
    saved, not_saved = [], []
    params[:new_skills].each do |skill|
      if current_user.skills << Skill.new(:name => skill, :source => 'linkedin')
        saved << skill
      else
        not_saved << skill
      end
    end
    
    unless saved.empty?
      current_user.linked_in_public_profile = params[:public_profile]
      current_user.save
    end
    
    flash[:notice] = "Skills saved: " + saved.join(', ') unless saved.empty?
    flash[:error] = "Not saved: " + not_saved.join(', ') unless not_saved.empty?
    
    redirect_to user_skills_path(current_user)
  end
  
  
protected

  def get_user
    current_user_id = (logged_in?) ? current_user.id : 0
    @user = (params[:user_id] == current_user_id) ? current_user : User.find(params[:user_id])
  end

end
