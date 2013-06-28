json.array! @tasks do |json, task|
  json.text task.name
  json.id task.id
end  