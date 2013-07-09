class TaggingsController < ApplicationController

  before_filter :find_issue, :only => [:issue]

  def issue
    @issue.tag_list = params[:tags]
    old_updated_on = Issue.find(@issue.id).updated_on
    @issue.save
    @issue.update_attributes(:updated_on => old_updated_on)

    respond_to do |format|
      format.html { render :nothing => true }
    end
  end
  
  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end
end
