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
    minWidth: 960
  })
  
  $('.hasAt').atwho({
    at: "@", 
    data: window._project_watchers,
    tpl: "<li data-pinyin='${pinyin}'> ${name} </li>"  ,
    callbacks: {
      filter: function(query, data, search_key) {
        var item, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          item = data[_i];
          if (~item[search_key].toLowerCase().indexOf(query) || ~item['pinyin'].toLowerCase().indexOf(query )) {
            _results.push(item);
          }
        }
        console.log(_results);        
        return _results;
      },
      sorter: function(query, items, search_key) {
         var item, _i, _len, _results;
         if (!query) {
           return items;
         }
         _results = [];
         for (_i = 0, _len = items.length; _i < _len; _i++) {
           item = items[_i];
           var name_order = item[search_key].toLowerCase().indexOf(query);
           var pinyin_order = item['pinyin'].toLowerCase().indexOf(query);           
           item.atwho_order = name_order > pinyin_order ? name_order : pinyin_order ;
           if (item.atwho_order > -1) {
             _results.push(item);
           }
         }
         return _results.sort(function(a, b) {
           return a.atwho_order - b.atwho_order;
         })
      }   
    }  
  });
  
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