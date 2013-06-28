# Redmine - project management software
# Copyright (C) 2006-2012  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class ProjectsController < ApplicationController
  menu_item :overview
  menu_item :roadmap, :only => :roadmap
  menu_item :settings, :only => :settings

  before_filter :find_project, :except => [ :index, :list, :new, :create, :copy ]
  before_filter :authorize, :except => [ :index, :list, :new, :create, :copy, :archive, :unarchive, :destroy, :quit, :mute, :change_creator]
  before_filter :authorize_global, :only => [:new, :create]
  before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy ]
  accept_rss_auth :index
  accept_api_auth :index, :show, :create, :update, :destroy

  after_filter :only => [:create, :edit, :update, :archive, :unarchive, :destroy] do |controller|
    if controller.request.post?
      controller.send :expire_action, :controller => 'welcome', :action => 'robots'
    end
  end

  helper :sort
  include SortHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :issues
  helper :queries
  include QueriesHelper
  helper :repositories
  include RepositoriesHelper
  include ProjectsHelper

  # Lists visible projects
  def index
    respond_to do |format|
      format.html {
        scope = Project
        unless params[:closed]
          scope = scope.active
        end
        @projects = scope.visible.order('lft').all
      }
      format.api  {
        @offset, @limit = api_offset_and_limit
        @project_count = Project.visible.count
        @projects = Project.visible.all(:offset => @offset, :limit => @limit, :order => 'lft')
      }
      format.atom {
        projects = Project.visible.find(:all, :order => 'created_on DESC',
                                              :limit => Setting.feeds_limit.to_i)
        render_feed(projects, :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
      }
    end
  end

  def new
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @trackers = Tracker.sorted.all
    @project = Project.new
    @project.safe_attributes = params[:project]
  end

  def create
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @trackers = Tracker.sorted.all
    @project = Project.new
    @project.safe_attributes = params[:project]
    @project.enabled_module_names = ["issue_tracking", "files", "wiki", "member_invitations"]
    @project.trackers = @trackers
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
    redirect_to project_issues_path(@project)
  end

  def copy
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @trackers = Tracker.sorted.all
    @root_projects = Project.find(:all,
                                  :conditions => "parent_id IS NULL AND status = #{Project::STATUS_ACTIVE}",
                                  :order => 'name')
    @source_project = Project.find(params[:id])
    if request.get?
      @project = Project.copy_from(@source_project)
      if @project
        @project.identifier = Project.next_identifier if Setting.sequential_project_identifiers?
      else
        redirect_to :controller => 'admin', :action => 'projects'
      end
    else
      Mailer.with_deliveries(params[:notifications] == '1') do
        @project = Project.new
        @project.safe_attributes = params[:project]
        if validate_parent_id && @project.copy(@source_project, :only => params[:only])
          @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
          flash[:notice] = l(:notice_successful_create)
          redirect_to :controller => 'projects', :action => 'settings', :id => @project
        elsif !@project.new_record?
          # Project was created
          # But some objects were not copied due to validation failures
          # (eg. issues from disabled trackers)
          # TODO: inform about that
          redirect_to :controller => 'projects', :action => 'settings', :id => @project
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :controller => 'admin', :action => 'projects'
  end
	
  # Show @project
  def show
    redirect_to project_issues_path(@project)
  end

  def settings
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @issue_category ||= IssueCategory.new
    @member ||= @project.members.new
    @trackers = Tracker.sorted.all
    @wiki ||= @project.wiki
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    if params[:project][:creator_id]
      unless @project.creator == User.current && @project.users.include?(User.find(params[:project][:creator_id]))
        redirect_to project_issues_path(@project) and return
      end
    end

    @trackers = Tracker.sorted.all
    @project.safe_attributes = params[:project]
    @project.trackers = @trackers

    if validate_parent_id && @project.save
      @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
    end
    redirect_to project_issues_path(@project)
  end

  def modules
    @project.enabled_module_names = params[:enabled_module_names]
    flash[:notice] = l(:notice_successful_update)
    redirect_to :action => 'settings', :id => @project, :tab => 'modules'
  end

  def archive
    if request.post?
      unless @project.archive
        flash[:error] = l(:error_can_not_archive_project)
      end
    end
    redirect_to(url_for(:controller => 'admin', :action => 'projects', :status => params[:status]))
  end

  def unarchive
    @project.unarchive if request.post? && !@project.active?
    redirect_to(url_for(:controller => 'admin', :action => 'projects', :status => params[:status]))
  end

  def close
    @project.archive
    redirect_to home_path
  end

  def reopen
    @project.unarchive
    redirect_to project_path(@project)
  end

  # Delete @project
  def destroy
    @project_to_destroy = @project
    if api_request? || params[:confirm]
      @project_to_destroy.destroy
      respond_to do |format|
        format.html { redirect_to :controller => 'admin', :action => 'projects' }
        format.api  { render_api_ok }
      end
    end
    # hide project in layout
    @project = nil
  end

  def quit
    @member = Member.find_by_project_id_and_user_id(@project, User.current)
    @member.destroy

    redirect_to home_path, notice: l(:notice_quit_project)
  end
  
  def mute
    @member = Member.find_by_project_id_and_user_id(@project, User.current)
    if @member.mute?
      @member.update_attributes({:mute => false})
    else
      @member.update_attributes({:mute => true})      
    end    

    respond_to do |format|
      format.js
    end

  end

  def change_creator
    @project = Project.find(@project.id) 
    @user = false
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
