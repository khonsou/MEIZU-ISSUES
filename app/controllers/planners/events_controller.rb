class Planners::EventsController < ApplicationController
  
  def index
    @project = Project.find_by_id(params[:project_id]) || Project.last
    @events = @project.events
    respond_to do |format|
      format.json
    end  
  end
  
  def create
    @project = Project.find_by_id(params[:project_id]) || Project.last
    @event = @project.events.build(params[:event])
    @event.save
    @event.insert_at(params[:event][:order]) if params[:event][:order].present?
    @events = @project.events        
    respond_to do |format|
      format.json 
    end  
  end
  
  def update
    @event = Event.find(params[:id])    
    @event.update_attributes params[:event]
    @event.insert_at(params[:event][:order]) if params[:event][:order].present?
    @events = @event.project.events        
    respond_to do |format|
      format.json 
    end  
  end
  
  def destroy
    @event = Event.find(params[:id])
    @events = @event.project.events
    @event.destroy
    respond_to do |format|
      format.json 
    end  
  end
  
  
end
