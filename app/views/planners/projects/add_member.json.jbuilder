json.array! @members do |json, member|
  json.name member.user.name
  json.id member.id
  if @project.creator == User.current
      json.deletable (@project.creator == member.user)? false:true
  else
    json.deletable false
  end
end  
