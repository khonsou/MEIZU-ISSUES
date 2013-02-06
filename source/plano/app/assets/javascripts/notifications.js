var load_popover_push_notifications = function() {
  $.ajax({
    url: '/push_notifications/popover',
    type: 'get'
  });
};

$(document).ready(function() {
  load_popover_push_notifications();
  setInterval(load_popover_push_notifications, 30 * 1000);
});
