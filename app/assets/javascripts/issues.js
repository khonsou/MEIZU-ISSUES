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
  return '<div id="'+ div_id +'">Loading...</div>' ;  
}

$(document).ready( function(){
  $('.select-menu-button').clickover({
      html: true,
      trigger: 'click',
      placement: 'right',
      content: function(){
        var div_id =  "div-id-" + $.now();
        return details_in_popup($(this).attr('href'), div_id)
      }      
  })      
  
  $(".pinned").pin({
    containerSelector: ".container" ,
    minHeight: 100,
    minWidth: 940
  })
  
  $('.hasAt').atwho({at:"@", 'data':window._project_watchers});
  
  $('a[data-format=true]').click(function(){
    $('#formatting-help').fadeIn();
    return false;
  })
  
  $("a.close").click(function(){
    $(this).parent().hide();  
    return false;
  })
  
  $('.tabnav li a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  })
})