class TaggingsController < ApplicationController

  before_filter :find_issue, :only => [:issue]

  def issue
    @issue.tag_list = params[:tags]
    @issue.save

    respond_to do |format|
      format.html { render :nothing => true }
    end
  end
  
  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end
end
