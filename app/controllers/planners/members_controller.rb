class Planners::MembersController < ApplicationController
  layout 'planner'
  
  def index    
    @users = User.active.where(admin: false).order('created_on desc').page(params[:page]).per(49)

    respond_to do |format|
      format.html      
      format.js
    end
  end
  
  def show
    @load_angular = true
    
    @user = User.find(params[:id])
    @projects = @user.projects
    @events_groups = @user.members.inject([]) {| ary, member | ary << member.events }
    @events_groups.reject! { |c| c.empty? }
        
    respond_to do |format|
      format.html
      format.json  #{render :json => @events_groups.to_json}
    end  
  end
  
  def create
    @project = Project.find_by_id(params[:project_id]) || Project.last
    @membet = @project.membets.build(params[:membet])
    @membet.save
    @membets = @project.membets        
    respond_to do |format|
      format.json 
    end  
  end
  
  def update
    @membet = Membet.find(params[:id])    
    @membet.update_attributes params[:membet]
    @membets = @membet.project.membets        
    respond_to do |format|
      format.json 
    end  
  end
  
  def destroy
    @member = Member.find(params[:id])
    if User.current == @member.project.creator
      @member.destroy
      @project = @member.project
    end
    respond_to do |format|
      format.json 
    end  
  end
  
  
end
