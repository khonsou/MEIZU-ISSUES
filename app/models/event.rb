#coding:utf-8
class Event < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :project
  belongs_to :eventable, polymorphic: true  
  
  validate :check_time
  
  acts_as_list :scope => :project
  
  def text
    if eventable_type == "Task"
      eventable.name
    else
      eventable.name
    end    
  end
  
  private
  def check_time
    if self.start_at > self.end_at
      self.errors.add(:start_at, "开始时间不能晚于结束时间") 
    end
  end
end
