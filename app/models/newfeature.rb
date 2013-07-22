class Newfeature < ActiveRecord::Base
  attr_accessible :description, :title

  validates :title, :presence => true
end
