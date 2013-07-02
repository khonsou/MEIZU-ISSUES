class Planners::ProjectsController < ApplicationController
  layout 'planner'

  def index

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

  private

  # Validates parent_id param according to user's permissions
  # TODO: move it to Project model in a validation that depends on User.current
  def validate_parent_id
    return true if User.current.admin?
debugger
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

