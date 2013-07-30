'use strict';

/* Directives */

angular.module('ginkgo.directives', []).
  directive('ginkgoDraggable', function () {
    return function(scope, element, attrs) {
        element.draggable({

          helper: 'clone',
//          revert: 'invalid',                  
          start: function(e, ui) {              
            if(ui.helper.hasClass('member')){
              ui.helper.children('a.destroy').remove();
            }                  
          }, 
          stop: function(e, ui) {  
            $('.tooltip').hide();                  
          },          
          revert: function (socketObj) {
            if ($(socketObj).offset() == null) {
              $(this).show();  
              $('.ui-state-highlight').hide();             
            }
          },
          drag: function(e, ui){
            
            var placeholder = $('<div class="ui-state-highlight"></div>');
            placeholder.height($(this).outerHeight());
            
            var rowIndex =  parseInt(($(ui.helper).offset().top - $('.month-row').offset().top) / 30);
            
            if($(this).data('event-id') != undefined){      
              if (rowIndex >= scope.events.length) {
                rowIndex = scope.events.length ;
              }else if(rowIndex < 0){
                rowIndex = 0;
              }
                         
              $(this).hide();                          
              if ($('.ui-state-highlight')[0] == undefined) {
                $(placeholder).insertBefore($(this).parents().find('div.tip').get(rowIndex));                                          
              }else {       
                $('.ui-state-highlight').remove();                            
                if ((rowIndex == scope.events.length )) {
                  $(placeholder).insertAfter($(this).parents().find('div.tip').get(rowIndex));                                                                                 
                }else {
                  $(placeholder).insertBefore($(this).parents().find('div.tip').get(rowIndex));              
                }       
              }        
            }else{
              
              if (rowIndex >= scope.events.length) {
                rowIndex = scope.events.length  ;
              }else if(rowIndex < 0){
                rowIndex = 0;
              }
              
              if ($('.ui-state-highlight')[0] == undefined) {
                $(placeholder).insertAfter($(this).parents().find('div.tip').get(rowIndex));                                          
              }else {       
                $('.ui-state-highlight').remove();                            
                if (rowIndex == 0 ) {
                  $(placeholder).insertBefore($(this).parents().find('div.tip').get(rowIndex));                                                          
                }else if(rowIndex == scope.events.length  ){
                  $(placeholder).insertAfter($(this).parents().find('div.tip').get(scope.events.length - 1));                                                            
                }else if(rowIndex == scope.events.length -1 ){
                  $(placeholder).insertBefore($(this).parents().find('div.tip').get(scope.events.length - 1));                                                                              
                }else {
                  $(placeholder).insertBefore($(this).parents().find('div.tip').get(rowIndex));                                        
                }       
              }        
            }       

    
          }
        });
      };              
  }).
  directive('ginkgoDroppable', function () {
    return function(scope, element, attrs) {
          
      element.droppable({
        tolerance: 'pointer',
        drop: function(event, ui ){
          $('.tooltip').hide();        

          if ($('.ui-state-highlight').index() == -1) {
            var rowIndex = scope.events.length  ;
          }else {
            var rowIndex =  parseInt(($('.ui-state-highlight').offset().top - $('.month-row').offset().top) / 30);
            if (rowIndex >= scope.events.length) {
              rowIndex = scope.events.length  ;
            }else if(rowIndex < 0){
              rowIndex = 0;
            }

          }         
          
          $('.ui-state-highlight').css('visibility', 'hidden');                                                                                           
          var date   = new Date($(this).find('.day:first').data('date'));              
          var range = scope.calculateHoverIndex(ui.helper, this, date);                     
          
          console.log(range) 
          var allDays = $(this).find('.day') ;                        
          var hoverColumns, startAt, endAt;
                                
          if($(ui.draggable).data('event-id') != undefined){
            // drag from inner calendar
            if (range.start < 0) {            
              hoverColumns = $(allDays).slice(0, range.end);
              endAt = $(hoverColumns).last().data('date') ;               
              startAt = $.datepicker.formatDate('yy-mm-dd', new Date(new Date(endAt) - (range.end - range.start) * 24 * 60 * 60 * 1000))            
            }else if(range.end > 31){
              hoverColumns = $(allDays).slice(range.start, 30);
              startAt = $(hoverColumns).first().data('date') ;
              endAt = $.datepicker.formatDate('yy-mm-dd', new Date(new Date(startAt).getTime() + (range.end - range.start) * 24 * 60 * 60 * 1000))           
            }else{
              hoverColumns = $(allDays).slice(range.start - 1, range.end - 1);                        
              startAt = $(hoverColumns).first().data('date') ;             
              endAt = $(hoverColumns).last().data('date') ;            
            }

            scope.$apply(function(){
              scope.updateEvent({
                event: {id: $(ui.helper).data('event-id'), 
                       start_at: startAt, 
                       end_at: endAt,
                       order: rowIndex
                     }
              })
            });  
          }else{
            // drag from outer calendar            
            if (range.start < 0) {            
              hoverColumns = $(allDays).slice(0, range.end);
              endAt = $(hoverColumns).last().data('date') ;
              startAt = new Date(new Date(endAt) - (range.end - range.start) * 24 * 60 * 60 * 1000).toString('yyyy-MM-dd')                                 
            
            }else if(range.end > 31){
              hoverColumns = $(allDays).slice(range.start, 30);
              startAt = $(hoverColumns).first().data('date') ;
              endAt = new Date(new Date(startAt) + (range.end - range.start) * 24 * 60 * 60 * 1000).toString('yyyy-MM-dd')                                 
            
            }else{
              hoverColumns = $(allDays).slice(range.start, range.end );
              startAt = $(hoverColumns).first().data('date') ;             
              endAt = $(hoverColumns).last().data('date') ;            
            }
            
            var eventableId, type;
            if($(ui.draggable).data('task-id') != undefined){
              eventableId = $(ui.draggable).data('task-id');
              type = 'Task';
            }else{
              eventableId = $(ui.draggable).data('member-id');              
              type = 'Member';              
            } 
            
            scope.$apply(function(){
              scope.addEvent({event: 
                {
                 start_at: startAt, 
                 end_at: endAt,
                 eventable_id: eventableId,
                 eventable_type: type,
                 order: rowIndex 
               }
              })          
            });          
       
          }        
                
        }
      });       
    };
  }).
  directive('ginkgoResizeable',  function () {
    return function(scope, element, attrs) {
      element.resizable({
        handles: "e",
        grid: scope.gridWidth ,
        resize: function(event, ui) {
          $(this).css('height', 'auto');
        },
        stop: function(event, ui) {

          var allDays = $(this).parents('.month-row').find('.days .day') ;        
          var date   = $(allDays[0]).data('date'); 
          var range = scope.calculateHoverIndexResize(ui.helper, $(this).parents('.month-row'), date);
          console.log(range)
          var hoverColumns , startAt, endAt;
          if(range.end > 31){
            hoverColumns = $(allDays).slice(range.start, 30);
            startAt = $(hoverColumns).first().data('date') ;
            endAt = $.datepicker.formatDate('yy-mm-dd', new Date(new Date(startAt).getTime() + (range.end  - range.start) * 24 * 60 * 60 * 1000))           
          }else{
            hoverColumns = $(allDays).slice(range.start, range.end);  
            startAt =  $(hoverColumns).first().data('date'), 
            endAt =  $(hoverColumns).last().data('date')            
          }  
                                           
          scope.$apply(function(){
            scope.updateEvent({
              event: {              
                id: $(ui.helper).data('event-id'), 
                start_at: startAt, 
                end_at: endAt
               }  
            })
          });  
        }
      });        
    }
  }).
  directive('ginkgoPopover', ['$rootScope', '$http', '$compile', function ($rootScope, $http, $compile) {
    return {
     link: function(scope, element, attrs) {

       // $http.get('partials/calendar_body.html', {cache: true}).then(function onSuccess(template) {
       //     // Handle response from $http promise
       //     var compile =  $compile(template.data)(scope);            
       //     $('#calendar .body').append(compile);          
       // })
       
       attrs.$observe('eventId', function(value) {         

         var event = _.find(scope.events, function(e){ return e.id == parseInt(value); }) 
         if (value) {
           var template = 
           '<div class="popover-content balloon right_side">' +
             '<span class="arrow"></span>' +
             '<form name="eventForm" class="form-horizontal">' +              
               '<div class="control-group">' + 
                 '<label class="control-label">开始</label>' + 
                 '<div class="controls"><input name="start" rel="date" value="{{event.startTime}}"></input></div>' +
               '</div>' +
               '<div class="control-group">' + 
                 '<label class="control-label">结束</label>' + 
               '<div class="controls"><input name="end" rel="date" value="{{event.endTime}}"></input></div>' +
               '</div>' +
             	'<p class="submit">' + 
             		'<input type="submit" value="保存" class="btn btn-small btn-success" ng-click="save()">' + 
                 '<a href="#" class="image delete pull-right" data-behavior="delete">删除</a>'
             	'</p>' +
             '</form>' +
             '</div>'              
             
             var compile =  $compile(template)(scope);
             element.on('click', function(e){
                var targetOffset = element.find('.title').offset(),
                    calendarItemEditorSingletonLeft = targetOffset.left + 10 + element.parents('.month-row').find('span.event').width(),
                    editActualWidth = $('#calendar_item_editor_singleton').children().first().width()+parseInt($('#calendar_item_editor_singleton').children().first().css("padding-left"))*2;

                $('#calendar_item_editor_singleton').html(compile);
                //Locate ballon
                if($(document).width() - targetOffset.left < editActualWidth){
                  calendarItemEditorSingletonLeft = calendarItemEditorSingletonLeft - editActualWidth-100;
                  $('#calendar_item_editor_singleton').find(".balloon").removeClass("right_side").addClass("left_side");
                  $('#calendar_item_editor_singleton').show()
                                                      .css('top', targetOffset.top)
                                                      .css('left',e.pageX - editActualWidth); 
                }else if(targetOffset.left<$(element).width()/2){
                  $('#calendar_item_editor_singleton').find(".balloon").removeClass("left_side").addClass("right_side");
                  $('#calendar_item_editor_singleton').show()
                                                      .css('top', targetOffset.top)
                                                      .css('left',e.pageX); 
                }else{
                  $('#calendar_item_editor_singleton').find(".balloon").removeClass("left_side").addClass("right_side");
                  $('#calendar_item_editor_singleton').show()
                                                      .css('top', targetOffset.top)
                                                      .css('left', calendarItemEditorSingletonLeft);                                                    
                }
               
                $('input[rel=date]').datepicker({});
                                                                    
                $('#calendar_item_editor_singleton').find('.cancel').on('click', function(){
                  $('#calendar_item_editor_singleton').hide();
                  $('input[rel=date]').datepicker('destroy');     
                  return false;                                   
                })                                            
                $('#calendar_item_editor_singleton').find('.delete').on('click', function(){
                  if(confirm('Are you sure delete this?')){
                    $('#calendar_item_editor_singleton').hide();                    
                    $('input[rel=date]').datepicker('destroy');                                    
                    scope.$apply(function(){
                      scope.destroyEvent(event);
                    });  
                  }
                }) 
                $('#calendar_item_editor_singleton').find('input[type=submit]').on('click', function(){
                  scope.$apply(function(){                                                            
                    var eventFormData = $('#calendar_item_editor_singleton').find('form').serializeObject() ;                                     
                    scope.updateEvent({
                      event: {                  
                        id: event.id,
                        start_at: eventFormData.start, 
                        end_at: eventFormData.end
                      }
                    })
                  });                    
                  $('#calendar_item_editor_singleton').hide();                                      
                })
                e.stopPropagation();                                                                                    
             })
         }
       });
    
     }
  }
}]).
  directive('ginkgoTaskPopover', ['$rootScope', '$http', '$compile', function ($rootScope, $http, $compile) {
    return {
     link: function(scope, element, attrs) {
       attrs.$observe('taskId', function(value) {            
           var task = _.find(scope.tasks, function(e){ return e.id == parseInt(value); })        
           scope.colors = ["#009900", '#aa0000', "#ec61a2", "#3185c5", "#46647c", "#b3a543",
                          "#ff9c00",  "#000000"];

           var template = 
           '<div class="popover-content balloon right_side">' +
             '<span class="arrow"></span>' +
             '<form name="eventForm" class="form-horizontal">' +     
                '<p>选择代表颜色</p>' +
                '<div class="swatches">' +          
                   '<span ng-repeat="color in colors">' +
                     '<input type="radio"  id="calendar_editor_singleton_swatch_{{$index}}" name="color" value="{{color}}">' +                      
                     '<label class="swatch" for="calendar_editor_singleton_swatch_{{$index}}" style="background-color: {{color}}"></label>' +           
                   '</span>' +                            
               '</div>' +         
               '<div class="control-group">' + 
                 '<label class="control-label">名字</label>' + 
                 '<div class="controls"><input name="text" value="{{ task.text }}"></input></div>' +
               '</div>' +
             	'<p class="submit">' + 
             		'<input type="submit" value="保存" class="btn btn-small btn-success" ng-click="save()">' + 
                 '<a href="#" class="image delete pull-right" data-behavior="delete">删除</a>'
             	'</p>' +
             '</form>' +
            '</div>'              
             
             var compile =  $compile(template)(scope);
             element.on('click', function(e){
               var targetOffset = element.offset();
               $('#calendar_item_editor_singleton').html(compile);
               $('#calendar_item_editor_singleton').show()
                                                   .css('top', targetOffset.top - 55).
                                                    css('left', targetOffset.left + 50);
                $('#calendar_item_editor_singleton').find('.cancel').on('click', function(){
                  $('#calendar_item_editor_singleton').hide();
                  return false;
                })                                            
                $('#calendar_item_editor_singleton').find('.delete').on('click', function(){
                  if(confirm('Are you sure delete this?')){
                    $('#calendar_item_editor_singleton').hide();                    
                    scope.$apply(function(){
                      scope.destroyTask(task);
                    });  
                  }
                }) 
                $('#calendar_item_editor_singleton').find('input[type=submit]').on('click', function(){                                                                  
//                  scope.$apply(function(){         
                    var eventFormData = $('#calendar_item_editor_singleton').find('form').serializeObject() ;                                     
                    scope.updateTask({
                      id: task.id,
                      task: {name: eventFormData.text,
                             color: eventFormData.color}
                    })
  //                });                    
                  $('#calendar_item_editor_singleton').hide();                                      
                })
                e.stopPropagation();                                                                                    
             })
    
        });
     }
  }
}]).directive('ginkgoInviteMember', ['$rootScope', '$http', '$compile', function ($rootScope, $http, $compile) {
    return {
      
      link: function(scope, element, attrs) {
        element.on('click', function(e){        
          $.get(element.attr('href'), function(data){
          }).always(function(data) { 
            if ($('#container-modal').length > 0) {
              $('#container-modal').modal('hide');
              $('#container-modal').remove();
            }
            var html = $compile(data.responseText)(scope);
            $("body").append(html)
            $('#container-modal').modal('show');          
          })
          
          return false;
        })  
      }
    } 
}]).directive('ginkgoDestroyMember', ['$rootScope', '$http', '$compile', function ($rootScope, $http, $compile) {
    return {
      
      link: function(scope, element, attrs) {
        attrs.$observe('memberId', function(value) {                    
          var member = _.find(scope.members, function(e){ return e.id == parseInt(value); })        
                   
          element.on('click', function(e){  
            if (confirm('你确定要删除该成员么？')) {
              scope.destroyMember(member);            
            }
          
            return false;
          })  
        }) 
      }
    } 
}]).       
directive('ginkgoNextMonth', ['$rootScope', '$http', '$compile', function ($rootScope, $http, $compile) {
  return {
    link: function(scope, element, attrs) {
      element.on('click', function(e){           
        $http.get('/assets/planners/partials/calendar.html', {cache: false}).then(function onSuccess(template) {
           // Handle response from $http promise
           var compile =  $compile(template.data)(scope);            
          
           $('#bigzone').append(compile);       
           $("#bigzone").css("-webkit-transform","translate(" + ($('.calendar-body').length - 1) * -$('.calendar-body:first').outerWidth() + "px, 0px)");              
//           $('.calendar-body:first').remove();
        });
      })
    }
  } 
}])


