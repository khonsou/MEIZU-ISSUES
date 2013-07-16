#Clean the invitations which are time out
sql = "delete from member_invitations where created_at <(now()-interval 3 day) and state = 'pending'"

ActiveRecord::Base.establish_connection

ActiveRecord::Base.connection.execute(sql)

