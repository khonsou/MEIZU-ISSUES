var load_popover_push_notifications = function() {
  $.ajax({
    url: '/push_notifications/popover',
    type: 'get'
  });
};

$(document).ready(function() {
  if(window._rails_env != "development"){
    load_popover_push_notifications();
    setInterval(load_popover_push_notifications, 60 * 1000); 
  }
});
