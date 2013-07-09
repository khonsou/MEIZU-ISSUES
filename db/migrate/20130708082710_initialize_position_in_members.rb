class InitializePositionInMembers < ActiveRecord::Migration
  def up
    user_ids = Member.select("distinct user_id").map{|m|m.user_id}
    user_ids.each do |user_id|
      members = Member.where(user_id: user_id).order("created_on desc")
      count = 0 
      members.each do |member|
        count += 1
        member.position = count
        member.save
      end 
    end
  end

  def down
  end
end
