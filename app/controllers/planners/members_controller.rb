class Planners::MembersController < ApplicationController
  
  def index
    @project = Project.find_by_id(params[:project_id]) || Project.last
    @membets = @project.membets
    respond_to do |format|
      format.json
    end  
  end
  
  def show
    @member = Member.find(params[:id])
    @events_groups = @member.user.members.inject([]) {| ary, member | ary << member.events }
    @events_groups.reject! { |c| c.empty? }
        
    respond_to do |format|
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
    @membet = Membet.find(params[:id])
    @membets = @membet.project.membets
    @membet.destroy
    respond_to do |format|
      format.json 
    end  
  end
  
  
end
