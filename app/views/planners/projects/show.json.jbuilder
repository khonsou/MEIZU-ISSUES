json.tasks @project.tasks do |json, task|
  json.text task.name
  json.color task.color  
  json.id task.id
end  

json.members @project.members do |json, member|
  json.name member.user.name
  json.id member.id
end  

json.events @project.events do |json, event|
  json.text event.text
  json.position event.position
  json.startTime event.start_at.strftime("%Y-%m-%d")
  json.endTime  event.end_at.strftime("%Y-%m-%d") 
  json.conflictStart event.conflict_start.try(:strftime, "%Y-%m-%d")
  json.conflictEnd event.conflict_end.try(:strftime, "%Y-%m-%d")
  json.eventableType event.eventable_type
  json.eventableId  event.eventable_id  
  json.color event.color  
  json.id event.id
  json.timestamp Time.now.to_i
end  
