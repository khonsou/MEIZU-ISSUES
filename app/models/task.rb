class Task < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :project
  has_many :events, :as => :eventable, :dependent => :destroy
   
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id
  
  COLOR = %W(#009900 #aa0000 #ec61a2 #3185c5 #46647c #b3a543 #ff9c00 #000000) 

end
