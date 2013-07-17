#Clean the invitations which are time out
puts "Cleaning start ..."
MemberInvitation.where("created_at < ? and state = ?",Time.now-3.days,'pending').destroy_all
puts "Cleaning up."
