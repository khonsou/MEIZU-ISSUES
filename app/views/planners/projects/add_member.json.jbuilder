json.array! @members do |json, member|
  json.name member.user.name
  json.id member.id
  json.icon member.user.avatar_url(:medium)
  if @project.creator == User.current
      json.deletable (@project.creator == member.user)? false:true
  else
    json.deletable false
  end
end  
