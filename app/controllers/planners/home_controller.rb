class Planners::HomeController < ApplicationController
  layout 'planner'
  before_filter :find_optional_project, :only => [:new_member, :add_member]

  def index
  	@projects = Project.order('created_on desc').page(params[:page]).per(8)
  	@users = User.active.where(admin: false).order('created_on desc').page(params[:page]).per(8)
    respond_to do |format|
      format.html      
      format.js
    end
  end
  
end
