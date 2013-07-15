json.array! @tasks do |json, task|
  json.text task.name
  json.color task.color
  json.id task.id
end  