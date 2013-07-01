class Event < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :project
  belongs_to :eventable, polymorphic: true  
  
  acts_as_list :scope => :project
  
  def text
    if eventable_type == "Task"
      eventable.name
    else
      eventable.name
    end    
  end
end
