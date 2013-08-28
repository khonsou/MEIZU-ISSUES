var load_popover_push_notifications = function(refresh) {
  var url = '/push_notifications/popover';
  if(refresh){ 
	url = url + "?refresh=1";
  }
  $.ajax({
    url: url,
    type: 'get'
  });
};

$(document).ready(function() {
  //if(window._rails_env != "development"){
    load_popover_push_notifications(true);
    setInterval(load_popover_push_notifications, 60 * 1000);
  //}
});
