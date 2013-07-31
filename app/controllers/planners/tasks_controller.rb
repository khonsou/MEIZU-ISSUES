class Planners::TasksController < ApplicationController
  layout 'planner'
  
  def index
    @project = Project.find_by_id(params[:project_id]) || Project.last
    @tasks = @project.tasks
    respond_to do |format|
      format.html 
      format.json
    end  
  end
  
  def create
    @project = Project.find_by_id(params[:project_id]) || Project.last
    @task = @project.tasks.build(:name =>  params[:text])
    @task.save          
    respond_to do |format|
      format.json 
    end  
  end
  
  def update
    @task = Task.find(params[:id])    
    @task.update_attributes params[:task]
    @project = @task.project
    respond_to do |format|
      format.json 
    end  
  end
  
  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    @project = Project.find(@task.project_id)        
    respond_to do |format|
      format.json 
    end  
  end
  
end
