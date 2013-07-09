#coding:utf-8
class Event < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :project
  belongs_to :eventable, polymorphic: true  
  
  validate :check_time
  
#  attr_accessor :conflict_start, :conflict_end
  
  acts_as_list :scope => :project
  
  default_scope order('position asc')
  
  attr_accessor :order
  
  def text
    if eventable_type == "Task"
      eventable.name
    else
      eventable.name
    end    
  end
  
  def conflict_start
    @conflict ||= check_conflict_in_project
    @conflict.first
  end
  
  def conflict_end
    @conflict ||= check_conflict_in_project
    @conflict.last
  end
  
  def check_conflict_in_project
    conflict_start = conflict_end = nil 
    
    return [conflict_start, conflict_end] if self.eventable_type != "User"
           
    ary = self.project.events.where("eventable_type = ? AND eventable_id = ?", 'User', self.eventable_id) - [self]
    ary.each do |event|
      if(!(self.start_at > event.end_at || self.end_at < event.start_at))
        if (self.start_at < event.start_at) 
          if (self.end_at < event.end_at) 
            conflict_start = event.start_at;
            conflict_end = self.end_at ;                
          else
            conflict_start = event.start_at;
            conflict_end = event.end_at ;                
          end
        else 
          if (self.end_at < event.end_at) 
            conflict_start = self.start_at;
            conflict_end = self.end_at ;                
          else
            conflict_start = self.start_at;
            conflict_end = event.end_at ;                
          end
        end          
      end 
    end  
    [conflict_start, conflict_end]     
  end
  
  private
  def check_time
    if self.start_at > self.end_at
      self.errors.add(:start_at, "开始时间不能晚于结束时间") 
    end
  end
end
