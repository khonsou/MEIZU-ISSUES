class Task < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :project
  
  validates_presence_of :name
end
