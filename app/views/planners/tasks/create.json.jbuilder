json.array! @project.tasks do |json, task|
  json.text task.name
  json.color :background => task.color
  json.id task.id
end  