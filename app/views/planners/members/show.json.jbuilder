json.events_groups @events_groups do |json, events|
  json.events  events do |je, event|
    je.text event.text
    json.position event.position    
    je.startTime event.start_at.strftime("%Y-%m-%d")
    je.endTime  event.end_at.strftime("%Y-%m-%d") 
    json.conflictStart event.conflict_start.try(:strftime, "%Y-%m-%d")
    json.conflictEnd event.conflict_end.try(:strftime, "%Y-%m-%d")    
    je.eventableType event.eventable_type
    je.eventableId  event.eventable_id  
    je.id event.id
    je.projectId event.project_id    
    je.color Event::COLOR[@events_groups.index(events) % Event::COLOR.size]
    je.projectName event.project.name
  end  
end  