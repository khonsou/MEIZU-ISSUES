var html = "";    
function changeAssign(div){
  $('.select-menu-item').removeClass('selected');
  $(div).addClass('selected');
  
  $('.select-assign input[type="radio"]').prop('checked', false)
  $(div).find('input').prop('checked', true);

  $.ajax({
    url: $(div).parents('form').attr("action"),
    dataType: "script",
    data: $(div).parents('form').serialize(),
    type: "PUT"
  });
  
} 

function details_in_popup(link, div_id){
  $.ajax({
    url: link,
    dataType: "script",
    type: "GET",
    complete: function(response){
      $('#'+div_id).html(response.responseText)
    }
  });
  return '<div id="'+ div_id +'">Loading...</div>'    ;  
}

$(document).ready( function(){
  $('#pencil').clickover({
      html: true,
      trigger: 'click',
      placement: 'right',
      title: "选择指派人",
      content: function(){
        var div_id =  "div-id-" + $.now();
        return details_in_popup($(this).attr('href'), div_id)
      }      
  })  
  

  $("input[data-picker=true]").datepicker({
    showOn: "button",
    buttonImage: "/assets/icon-edit.png",
    buttonImageOnly: true,
    onSelect: function(date){
      $.ajax({
        url: $(this).data('url'),
        dataType: "script",
        data: "issue[due_date]=" + date ,
        type: "PUT"
      });     
    }
  });
    
})