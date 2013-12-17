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

function listFilter(header, list) { 
  // header is any element, list is an unordered list
  // create and add the filter form to the header
  var form = $("<form>").attr({"class":"filterform","action":"#"}),
      input = $("<input>").attr({"class":"filterinput","type":"text","placeholder":"筛选" });
  $(form).append(input).prependTo(header);

  $(input)
    .change( function () {
      var filter = $(this).val();
      if(filter) {
        // this finds all links in a list that contain the input,
        // and hide the ones not containing the input while showing the ones that do
                
        $(list).find("h4").each(function(index){
          var name_order = $(this).text().toLowerCase().indexOf(filter);
          var pinyin_order = $(this).data('pinyin').toLowerCase().indexOf(filter);           
          var order = name_order > pinyin_order ? name_order : pinyin_order ;  
          if (order <= -1) {
            $(this).parents('.select-menu-item').hide()
          }else{
            $(this).parents('.select-menu-item').show()
          }            
        })
      } else {
        $(list).find("div.select-menu-item").show();
      }
      return false;
    })
  .keyup( function () {
      // fire the above change event after every letter
      $(this).change();
  })
  .keydown( function () {
      // fire the above change event after every letter
      $(this).change();
  })
  ;
}



function initAt(){

  
  $('.hasAt').atwho({
    at: "@", 
    data: window._project_watchers,
    limit: 2000,
    tpl: "<li data-pinyin='@${pinyin}' data-value='@${name}'> ${name} </li>"  ,
    callbacks: {      
      matcher: function(flag, subtext) {
        flag = flag.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
        regexp = new RegExp(flag + '([A-Za-z0-9_\+\-]*)$|' + flag + '([^\\x00-\\xff]*)$', 'gi');
        match = regexp.exec(subtext);
        if (match) {
          return match[2] || match[1];
        } else {
          return null;
        }
      },
      filter: function(query, data, search_key) {
        var item, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          item = data[_i];
          if (~item[search_key].toLowerCase().indexOf(query) || ~item['pinyin'].toLowerCase().indexOf(query )) {
            _results.push(item);
          }
        }
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
  }).atwho({
    at: "#", 
    search_key: "subject",
    data:  window._issues,
    limit: 5,
    tpl: "<li  data-value='#${id}'> ${id} ${subject} </li>"  ,   
    callbacks: {      
      remote_filter: function(query, callback) {
        $.getJSON("/projects/" + window._project_id + "/issues.json", {q: query}, function(data) {
          callback(data.issues)
        });
      }
    }  
  });        
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
  
  initAt();  
  
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
  

  $('body').tooltip({
    selector: '.tip'
  });
  
  $('textarea.autosize').autosize({append: "\n"});   

   $('#notes').bind('paste',function(event){
      var that = this;
       event.clipboardData = event.originalEvent.clipboardData;
       if(!event.clipboardData){
          return;
       }
       Array.prototype.forEach.call(
          event.clipboardData.types,function(type,i){
          if(event.clipboardData.items[i].type.match(/image.*/)){
                var items = event.clipboardData.items;
                var dropzone =  Dropzone.forElement('#dropzone');
                dropzone._addFilesFromItems(items);
             }
          }
       )
   });
})
