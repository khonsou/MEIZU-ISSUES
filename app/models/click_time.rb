class ClickTime < ActiveRecord::Base
  attr_accessible :user_id, :click_time

  def self.update_time(user_id)
    click_time = ClickTime.find_or_create_by_user_id(user_id)
    click_time.update_attributes(:click_time => Time.now)
  end

end
