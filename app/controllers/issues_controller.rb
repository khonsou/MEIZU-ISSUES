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

class IssuesController < ApplicationController
  menu_item :new_issue, :only => [:new, :create]
  default_search_scope :issues

  before_filter :find_issue, :only => [:show, :edit, :update, :close, :reopen]
  before_filter :find_issues, :only => [:bulk_edit, :bulk_update, :destroy]
  before_filter :find_project, :only => [:new, :create]
  before_filter :authorize, :except => [:index, :assigned_to_me, :reported, :watched, :closed, :close, :reopen, :search]
  before_filter :find_optional_project, :only => [:index, :assigned_to_me, :reported, :watched, :closed, :search]
  before_filter :sort_issues, :only => [:index, :assigned_to_me, :reported, :watched, :closed]
  before_filter :check_for_default_issue_status, :only => [:new, :create]
  before_filter :build_new_issue_from_params, :only => [:new, :create]
  before_filter :find_issues_with_project, only: [:index, :assigned_to_me, :reported, :watched, :closed, :search]
  before_filter :load_issues_count, only: [:index, :assigned_to_me, :reported, :watched, :closed]

  accept_rss_auth :index, :show
  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :journals
  helper :projects
  include ProjectsHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :issue_relations
  include IssueRelationsHelper
  helper :watchers
  include WatchersHelper
  helper :attachments
  include AttachmentsHelper
  # helper :queries
  # include QueriesHelper
  helper :repositories
  include RepositoriesHelper
  # helper :sort
  # include SortHelper
  include IssuesHelper
  helper :timelog
  include Redmine::Export::PDF

  def index
    if params[:q].present?
      @issues = @issues.open.where(" subject LIKE ?", "%#{params[:q]}%").order('issues.created_on DESC').limit(5)      
    else  
      @issues = @issues.open
      process_issues
    end  
  end

  def assigned_to_me
    @issues = @issues.open.assigned_to(User.current)
    process_issues
  end

  def reported
    @issues = @issues.open.reported_by(User.current)
    process_issues
  end

  def watched
    @issues = @issues.open.watched_by(User.current)
    process_issues
  end

  def closed
    @issues = @issues.open(false)
    process_issues
  end

  def show
    @journals = @issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_on ASC")
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?

    @changesets = @issue.changesets.visible.all
    @changesets.reverse! if User.current.wants_comments_in_reverse_order?

    @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
    @priorities = IssuePriority.active
    @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)

    @issue.push_notifications.each { |pn| pn.mark_as_read(User.current) }
    @journals.map(&:push_notifications).flatten.each { |pn| pn.mark_as_read(User.current) }
    @journals.map(&:details).flatten.map(&:push_notifications).flatten.each { |pn| pn.mark_as_read(User.current) }

    respond_to do |format|
      format.html {
        render :template => 'issues/show'
      }
      format.api
      format.atom { render :template => 'journals/index', :layout => false, :content_type => 'application/atom+xml' }
      format.pdf  { send_data(issue_to_pdf(@issue), :type => 'application/pdf', :filename => "#{@project.identifier}-#{@issue.id}.pdf") }
      format.js
    end
  end

  # Add a new issue
  # The new issue will be created from an existing one if copy_from parameter is given
  def new
    respond_to do |format|
      format.html { render :action => 'new', :layout => !request.xhr? }
      format.js
    end
  end

  def create
    call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    if @issue.save
      call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
      respond_to do |format|
        format.html {
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_issue_successful_create, :id => view_context.link_to("##{@issue.id}", issue_path(@issue), :title => @issue.subject))
          redirect_to project_issues_path(@issue.project)
        }
        format.api  { render :action => 'show', :status => :created, :location => issue_url(@issue) }
      end
      return
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@issue) }
      end
    end
  end

  def edit
    return unless update_issue_from_params

    respond_to do |format|
      format.html { }
      format.js
      format.xml  { }
    end
  end

  def update
    return if @issue.closed?

    return unless update_issue_from_params
    unless params[:remove_attachments].blank?
      @issue.delete_attachments(params[:remove_attachments].split(/,/))
    end
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    saved = false
    begin
      saved = @issue.save_issue_with_child_records(params, @time_entry)
    rescue ActiveRecord::StaleObjectError
      @conflict = true
      if params[:last_journal_id]
        @conflict_journals = @issue.journals_after(params[:last_journal_id]).all
      end
    end

    if saved
      render_attachment_warning_if_needed(@issue)

      @journals = @issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_on ASC")
      @issue.push_notifications.each { |pn| pn.mark_as_read(User.current) }
      if(params[:commit] != l(:button_close_submit))
        respond_to do |format|
          format.html do
            flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?          
            redirect_back_or_default({:action => 'show', :id => @issue})
          end  
          format.api  { render_api_ok }
          format.js 
        end
      else
        close

      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api  { render_validation_errors(@issue) }
        format.js { render :text => "alert('#{@issue.errors.full_messages}');"}
      end
    end
  end

  # Bulk edit/copy a set of issues
  def bulk_edit
    @issues.sort!
    @copy = params[:copy].present?
    @notes = params[:notes]

    if User.current.allowed_to?(:move_issues, @projects)
      @allowed_projects = Issue.allowed_target_projects_on_move
      if params[:issue]
        @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:issue][:project_id].to_s}
        if @target_project
          target_projects = [@target_project]
        end
      end
    end
    target_projects ||= @projects

    if @copy
      @available_statuses = [IssueStatus.default]
    else
      @available_statuses = @issues.map(&:new_statuses_allowed_to).reduce(:&)
    end
    @custom_fields = target_projects.map{|p|p.all_issue_custom_fields}.reduce(:&)
    @assignables = target_projects.map(&:assignable_users).reduce(:&)
    @trackers = target_projects.map(&:trackers).reduce(:&)
    @versions = target_projects.map {|p| p.shared_versions.open}.reduce(:&)
    @categories = target_projects.map {|p| p.issue_categories}.reduce(:&)
    if @copy
      @attachments_present = @issues.detect {|i| i.attachments.any?}.present?
      @subtasks_present = @issues.detect {|i| !i.leaf?}.present?
    end

    @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)
    render :layout => false if request.xhr?
  end

  def bulk_update
    @issues.sort!
    @copy = params[:copy].present?
    attributes = parse_params_for_bulk_issue_attributes(params)

    unsaved_issue_ids = []
    moved_issues = []

    if @copy && params[:copy_subtasks].present?
      # Descendant issues will be copied with the parent task
      # Don't copy them twice
      @issues.reject! {|issue| @issues.detect {|other| issue.is_descendant_of?(other)}}
    end

    @issues.each do |issue|
      issue.reload
      if @copy
        issue = issue.copy({},
          :attachments => params[:copy_attachments].present?,
          :subtasks => params[:copy_subtasks].present?
        )
      end
      journal = issue.init_journal(User.current, params[:notes])
      issue.safe_attributes = attributes
      call_hook(:controller_issues_bulk_edit_before_save, { :params => params, :issue => issue })
      if issue.save
        moved_issues << issue
      else
        # Keep unsaved issue ids to display them in flash error
        unsaved_issue_ids << issue.id
      end
    end
    set_flash_from_bulk_issue_save(@issues, unsaved_issue_ids)

    if params[:follow]
      if @issues.size == 1 && moved_issues.size == 1
        redirect_to :controller => 'issues', :action => 'show', :id => moved_issues.first
      elsif moved_issues.map(&:project).uniq.size == 1
        redirect_to :controller => 'issues', :action => 'index', :project_id => moved_issues.map(&:project).first
      end
    else
      redirect_back_or_default({:controller => 'issues', :action => 'index', :project_id => @project})
    end
  end

  def destroy
    @hours = TimeEntry.sum(:hours, :conditions => ['issue_id IN (?)', @issues]).to_f
    if @hours > 0
      case params[:todo]
      when 'destroy'
        # nothing to do
      when 'nullify'
        TimeEntry.update_all('issue_id = NULL', ['issue_id IN (?)', @issues])
      when 'reassign'
        reassign_to = @project.issues.find_by_id(params[:reassign_to_id])
        if reassign_to.nil?
          flash.now[:error] = l(:error_issue_not_found_in_project)
          return
        else
          TimeEntry.update_all("issue_id = #{reassign_to.id}", ['issue_id IN (?)', @issues])
        end
      else
        # display the destroy form if it's a user request
        return unless api_request?
      end
    end
    @issues.each do |issue|
      begin
        issue.reload.destroy unless issue.closed?
      rescue ::ActiveRecord::RecordNotFound # raised by #reload if issue no longer exists
        # nothing to do, issue was already deleted (eg. by a parent)
      end
    end
    respond_to do |format|
      format.html { redirect_back_or_default(:action => 'index', :project_id => @project) }
      format.api  { render_api_ok }
    end
  end

  def close
    @issue.init_journal(User.current, @notes)
    @issue.close

    redirect_to issue_path(@issue)
  end

  def reopen
    @issue.init_journal(User.current, @notes)
    @issue.reopen

    redirect_to issue_path(@issue)
  end

private
  def find_issue
    # Issue.visible.find(...) can not be used to redirect user to the login form
    # if the issue actually exists but requires authentication
    @issue = Issue.find(params[:id], :include => [:project, :tracker, :status, :author, :priority, :category])
    unless @issue.visible?
      deny_access
      return
    end
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    unless project_id.blank?
      @project = Project.find(project_id)
    else
      @project = Project.all(:conditions => Project.allowed_to_condition(User.current, :add_issues)).last
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Used by #edit and #update to set some common instance variables
  # from the params
  # TODO: Refactor, not everything in here is needed by #edit
  def update_issue_from_params
    @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
    @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
    @time_entry.attributes = params[:time_entry]

    @notes = params[:notes] || (params[:issue].present? ? params[:issue][:notes] : nil)
    @issue.init_journal(User.current, @notes)

    issue_attributes = params[:issue]
    if issue_attributes && params[:conflict_resolution]
      case params[:conflict_resolution]
      when 'overwrite'
        issue_attributes = issue_attributes.dup
        issue_attributes.delete(:lock_version)
      when 'add_notes'
        issue_attributes = {}
      when 'cancel'
        redirect_to issue_path(@issue)
        return false
      end
    end
    @issue.safe_attributes = issue_attributes
    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    true
  end

  # TODO: Refactor, lots of extra code in here
  # TODO: Changing tracker on an existing issue should not trigger this
  def build_new_issue_from_params
    if params[:id].blank?
      @issue = Issue.new
      if params[:copy_from]
        begin
          @copy_from = Issue.visible.find(params[:copy_from])
          @copy_attachments = params[:copy_attachments].present? || request.get?
          @copy_subtasks = params[:copy_subtasks].present? || request.get?
          @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks)
        rescue ActiveRecord::RecordNotFound
          render_404
          return
        end
      end
      @issue.project = @project
    else
      @issue = @project.issues.visible.find(params[:id])
    end

    @issue.project = @project
    @issue.author ||= User.current
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      render_error l(:error_no_tracker_in_project)
      return false
    end
    @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?
    @issue.safe_attributes = params[:issue]

    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)
    @available_watchers = (@issue.project.users.sort + @issue.watcher_users).uniq
  end

  def check_for_default_issue_status
    if IssueStatus.default.nil?
      render_error l(:error_no_default_issue_status)
      return false
    end
  end

  def parse_params_for_bulk_issue_attributes(params)
    attributes = (params[:issue] || {}).reject {|k,v| v.blank?}
    attributes.keys.each {|k| attributes[k] = '' if attributes[k] == 'none'}
    if custom = attributes[:custom_field_values]
      custom.reject! {|k,v| v.blank?}
      custom.keys.each do |k|
        if custom[k].is_a?(Array)
          custom[k] << '' if custom[k].delete('__none__')
        else
          custom[k] = '' if custom[k] == '__none__'
        end
      end
    end
    attributes
  end

  def find_issues_with_project
    @issues = @project.blank? ? Issue.visible : @project.issues.visible
  end

  def sort_issues
    @sort_types = ["updated_on", "due_date", "created_on"]
    @selected_sort_type = @sort_types.include?(params[:sort_by]) ? params[:sort_by] : @sort_types.first
    @order_command = case @selected_sort_type
    when "updated_on"
      "#{Issue.table_name}.updated_on DESC"
    when "created_on"
      "#{Issue.table_name}.created_on DESC"
    else
      "#{Issue.table_name}.due_date IS NULL, #{Issue.table_name}.due_date"
    end
  end

  def load_issues_count
    @issues_count = {
      open: @issues.open.count,
      assigned_to_me: @issues.open.assigned_to(User.current).count,
      reported: @issues.open.reported_by(User.current).count,
      watched: @issues.open.watched_by(User.current).count,
      closed: @issues.open(false).count
    }
  end

  def process_issues
    @issues = @issues.order(@order_command)

    @max_limit = @issues.count
    if params[:limit] && params[:limit].to_i > 0
      @limit = params[:limit].to_i
    else
      @limit = Issue.per_page
    end
    @issues = @issues.offset(@limit - Issue.per_page).limit(@limit)

    render 'index'
  end
end