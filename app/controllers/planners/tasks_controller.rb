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
    @tasks = @project.tasks        
    respond_to do |format|
      format.json 
    end  
  end
  
  def update
    @task = Task.find(params[:id])    
    @task.update_attributes params[:task]
    @tasks = @task.project.tasks        
    respond_to do |format|
      format.json 
    end  
  end
  
  def destroy
    @task = Task.find(params[:id])
    @tasks = @task.project.tasks
    @task.destroy
    respond_to do |format|
      format.json 
    end  
  end
  
end
