json.array! @members do |json, member|
  json.name member.user.name
  json.id member.id
end  