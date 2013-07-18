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

class SearchController < ApplicationController
  before_filter :find_optional_project, :load_sort_type

  helper :messages
  include MessagesHelper

  def index
    @question = params[:q] || ""
    @question.strip!

    projects_to_search =
      case params[:scope]
      when 'all'
        nil
      when 'my_projects'
        User.current.memberships.collect(&:project)
      when 'subprojects'
        @project ? (@project.self_and_descendants.active.all) : nil
      else
        @project
      end

    offset = nil
    begin; offset = params[:offset].to_time if params[:offset]; rescue; end

    # quick jump to an issue
    if @question.match(/^#?(\d+)$/) && Issue.visible.find_by_id($1.to_i)
      redirect_to :controller => "issues", :action => "show", :id => $1
      return
    end

    @object_types = Redmine::Search.available_search_types.dup
    if projects_to_search.is_a? Project
      # don't search projects
      @object_types.delete('projects')
      # only show what the user is allowed to view
      @object_types = @object_types.select {|o| User.current.allowed_to?("view_#{o}".to_sym, projects_to_search)}
    end

    @scope = @object_types.select {|t| params[t]}
    @scope = @object_types if @scope.empty?

    # extract tokens from the question
    # eg. hello "bye bye" => ["hello", "bye bye"]
    @tokens = @question.scan(%r{((\s|^)"[\s\w]+"(\s|$)|\S+)}).collect {|m| m.first.gsub(%r{(^\s*"\s*|\s*"\s*$)}, '')}
    # tokens must be at least 2 characters long
    @tokens = @tokens.uniq.select {|w| w.length > 0 }

    if !@tokens.empty? || still_try_to_search_when_query_is_empty?
      # no more than 5 tokens to search for
      @tokens.slice! 5..-1 if @tokens.size > 5

      # Not to show wiki or files when query is empty
      @scope = ['issues'] if @tokens.empty?

      @results = []
      @results_by_type = Hash.new {|h,k| h[k] = 0}
      @results_by_project = Hash.new {|h,k| h[k] = 0}

      @extra_conditions = Hash.new { |h,k| h[k] = [] }

      case params[:issue_status]
      when 'open'
        @extra_conditions['issues'] << "#{IssueStatus.table_name}.is_closed = FALSE"
      when 'close'
        @extra_conditions['issues'] << "#{IssueStatus.table_name}.is_closed = TRUE"
      end

      unless params[:due_date_start].blank?
        params[:due_date_start] = params[:due_date_start].to_date
        @extra_conditions['issues'] << "#{Issue.table_name}.due_date>='#{params[:due_date_start]}'"
      end
      unless params[:due_date_end].blank?
        params[:due_date_end] = params[:due_date_end].to_date
        @extra_conditions['issues'] << "#{Issue.table_name}.due_date<='#{params[:due_date_end]}'"
      end

      unless params[:created_on_start].blank?
        params[:created_on_start] = params[:created_on_start].to_date
        @extra_conditions['issues'] << "#{Issue.table_name}.created_on>='#{params[:created_on_start]}'"
      end
      unless params[:created_on_end].blank?
        params[:created_on_end] = params[:created_on_end].to_date
        @extra_conditions['issues'] << "#{Issue.table_name}.created_on<='#{params[:created_on_end]}'"
      end
      unless params[:issue_assigned_to_id].blank?
        @extra_conditions['issues'] << "#{Issue.table_name}.assigned_to_id = #{params[:issue_assigned_to_id]}"
        @user = User.find(params[:issue_assigned_to_id])
      end

      @tags_list = []
      unless params["hidden-tag_list"].blank?
        issue_ids = Tag.get_issue_ids_for_tag_list(params["hidden-tag_list"])
        if issue_ids.empty?
          @extra_conditions['issues'] << "#{Issue.table_name}.id is null"
        else
          @extra_conditions['issues'] << "#{Issue.table_name}.id IN (#{issue_ids.join(', ')})"
        end
        @tags_list = params["hidden-tag_list"].split(/,\s*/)
      end

      watched_issues = Issue.watched_by(User.current)
      case params[:issue_watched]
      when 'yes'
        @extra_conditions['issues'] << "#{Issue.table_name}.id IN (#{watched_issues.map(&:id).join(',')})"
      when 'no'
        @extra_conditions['issues'] << "#{Issue.table_name}.id NOT IN (#{watched_issues.map(&:id).join(',')})"
      end

      @scope.each do |s|
        result, result_count, project_count = s.singularize.camelcase.constantize.search(@tokens, projects_to_search,
          :all_words => true,
          :titles_only => false,
          :extra_conditions => @extra_conditions[s].join(' AND '),
          :offset => offset,
          :before => params[:previous].nil?)
        @results += result
        @results_by_type[s] += result_count
        # @results_by_project.merge!(project_count) { |project, oldval, newval| oldval + newval }
      end

      @scope.each do |s|
        result, result_count, project_count = s.singularize.camelcase.constantize.search(@tokens, nil,
          :all_words => true,
          :titles_only => false,
          :extra_conditions => @extra_conditions[s].join(' AND '),
          :offset => offset,
          :before => params[:previous].nil?)
        @results_by_project.merge!(project_count) { |project, oldval, newval| oldval + newval }
      end

      @results = sort_result(@results)
      @results = limit_result(@results)
    else
      @question = ""
    end
  end

private
  def still_try_to_search_when_query_is_empty?
    !( params[:due_date_start].blank? &&
       params[:due_date_end].blank? &&
       params[:created_on_start].blank? &&
       params[:created_on_end].blank? &&
       params[:issue_assigned_to_id].blank? &&
       params["hidden-tag_list"].blank? )
  end

  def find_optional_project
    return true unless (params[:project_id] || params[:id])
    unless params[:project_id].blank?
      @project = Project.find(params[:project_id])
    else
      @project = Project.find(params[:id])
    end
    check_project_privacy
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def load_sort_type
    @sort_types = ["updated_on", "due_date", "created_on"]
    @selected_sort_type = @sort_types.include?(params[:sort_by]) ? params[:sort_by] : @sort_types.first
  end

  def sort_result(unsort_result)
    case @selected_sort_type
    when "updated_on"
      unsort_result.sort { |a, b|
        a_datetime = a.respond_to?(:updated_on) ? a.updated_on : a.created_on
        b_datetime = b.respond_to?(:updated_on) ? b.updated_on : b.created_on
        b_datetime <=> a_datetime
      }
    when "created_on"
      unsort_result.sort { |a, b| b.created_on <=> a.created_on }
    when "due_date"
      unsort_result.sort do |a, b|
        if !a.respond_to?(:due_date) || a.due_date.blank?
          if !b.respond_to?(:due_date) || b.due_date.blank?
            0
          else
            1
          end
        else
          if !b.respond_to?(:due_date) || b.due_date.blank?
            -1
          else
            a.due_date <=> b.due_date
          end
        end
      end
    end
  end

  def limit_result(unlimited_result)
    @max_limit = unlimited_result.count
    if params[:limit] && params[:limit].to_i > 0
      @limit = params[:limit].to_i
    else
      @limit = 20
    end
    unlimited_result[0..@limit - 1]
  end
end
