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
    @skill = current_user.skills.new

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
    @skill = current_user.skills.new(params[:skill])

    respond_to do |format|
      if @skill.save
        flash[:notice] = 'Skill was successfully created.'
        format.html { redirect_to(user_skills_path(current_user)) }
        format.xml  { render :xml => @skill, :status => :created, :location => @skill }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @skill.errors, :status => :unprocessable_entity }
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
  
protected

  def get_user
    @user = (params[:user_id] == current_user.id) ? current_user : User.find(params[:user_id])
  end

end
