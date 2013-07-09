function sortList(obj,item)  
{  
    var srcPrjId,currentPosition;

    $(obj).sortable({  
          axis: 'y',  
          dropOnEmpty: false,   
          cursor: 'crosshair',  
          items: item,  
          opacity: 0.4,  
          scroll: true,  
          update: function(){  
            $.ajax({  
              type: 'post',  
              data: "prjId=" + srcPrjId + "&currentPosition=" + currentPosition,
              dataType: 'script',/* 
              complete: function(request){  
                $(obj).effect('highlight');  
              },  */
              url: "/projects/" + srcPrjId + "/memberships/sort"

            });  
          },
          beforeStop:function( event, ui )  {
            currentPosition = ui.item.index()+1;
            srcPrjId = ui.item[0].id;
          }
    });  
}  
$(function(){  
    sortList(".media-list",".media");  
})  
