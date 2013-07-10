class Planners::ProjectsController < ApplicationController
  layout 'planner'
  before_filter :find_optional_project, :only => [:new_member, :add_member]

  def index
    @projects = Project.order('created_on desc').page(params[:page]).per(10)
    respond_to do |format|
      format.html      
      format.js
    end          
  end

  def new
    @project = Project.new
    @project.safe_attributes = params[:project]
  end

  def create
    trackers = Tracker.sorted.all
    @project = Project.new
    @project.safe_attributes = params[:project]
    @project.enabled_module_names = ["issue_tracking", "files", "wiki", "member_invitations"]
    @project.trackers = trackers
    @project.is_public = false

    if validate_parent_id && @project.save
      @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
      # Add current user as a project member if he is not admin
      unless User.current.admin?
        r = Role.givable.find_by_id(Setting.new_project_user_role_id.to_i) || Role.givable.first
        m = Member.new(:user => User.current, :roles => [r])
        @project.members << m
      end
    end
    redirect_to planners_path
  end
  
  def show
    @project = Project.find params[:id]
    respond_to do |format|
      format.html      
      format.json 
    end      
  end

  def edit
    @project = Project.find params[:id]
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @project = Project.find params[:id]
    
    if params[:project][:creator_id]
      unless @project.creator == User.current && @project.users.include?(User.find(params[:project][:creator_id]))
        redirect_to planners_project_path(@project) and return
      end
    end

    @trackers = Tracker.sorted.all
    @project.safe_attributes = params[:project]
    @project.trackers = @trackers

    if validate_parent_id && @project.save
      @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
    end
    redirect_to planners_project_path(@project)
  end

  def new_member
    @all_users=User.status(User::STATUS_ACTIVE)
    @recipients=[]
    if params[:user_id]
       user=User.find(params[:user_id])
       @recipients << user
    end
  end
   
  def add_member
    if @project
      mails = params[:recipients].split(',').map{|m| User.parse_mail(m)}.compact.uniq
      if mails
         members=[]
         mails.each do |m|
           members << User.find_by_login(m)
         end
         Member.add_member(@project.id,members,params[:description])
      end
    end
    @members = @project.members
    respond_to do |format|     
      format.json 
    end      
  end

  private

  # Validates parent_id param according to user's permissions
  # TODO: move it to Project model in a validation that depends on User.current
  def validate_parent_id
    return true if User.current.admin?
    parent_id = params[:project] && params[:project][:parent_id]
    if parent_id || @project.new_record?
      parent = parent_id.blank? ? nil : Project.find_by_id(parent_id.to_i)
      unless @project.allowed_parents.include?(parent)
        @project.errors.add :parent_id, :invalid
        return false
      end
    end
    true
  end

  
end

