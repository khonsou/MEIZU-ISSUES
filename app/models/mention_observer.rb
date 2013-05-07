class MentionObserver < ActiveRecord::Observer
  observe :issue, :journal
  
  def after_create(model)
    
  end
    
end