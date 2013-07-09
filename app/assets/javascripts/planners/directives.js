'use strict';

/* Directives */

angular.module('ginkgo.directives', []).
  directive('ginkgoDraggable', function () {
    return function(scope, element, attrs) {
        element.draggable({
          revert: 'invalid',
          helper: 'clone',
          drag: function( event, ui ) {
            var range = scope.calculateHoverIndex(ui.helper);
            var allDays = $(this).parents('.month-row').find('.days .day') ;        
            var hoverColumns = $(allDays).slice(range.start, range.end);
          }
        });
      };              
  }).
  directive('ginkgoDroppable', function () {
    return function(scope, element, attrs) {
          
      element.droppable({
        drop: function(event, ui ){
          var rowIndex = $('.month-row').index($(this).parents(".month-row"));                                
          var allDays = $(this).find('.day') ;                            
          var range = scope.calculateHoverIndex(ui.helper);
          
          if($(ui.draggable).data('event-id') != undefined){
            // drag from inner calendar
            var hoverColumns = $(allDays).slice(range.start, range.end);          

            scope.$apply(function(){
              scope.updateEvent({
                event: {id: $(ui.helper).data('event-id'), 
                       start_at: $(hoverColumns).first().data('date'), 
                       end_at: $(hoverColumns).last().data('date'),
                       order: rowIndex
                     }
              })
            });  

          }else{
            // drag from outer calendar
            var hoverColumns = $(allDays).slice(range.start, range.end + 5);// + 5 is for make the length longer          
            // if (scope.hasEventByTagId($(ui.draggable).data('tag-id'))) {
            //   alert('this tag already in');
            //   return false;                
            // }
            
            var eventableId, type;
            if($(ui.draggable).data('task-id') != undefined){
              eventableId = $(ui.draggable).data('task-id');
              type = 'Task';
            }else{
              eventableId = $(ui.draggable).data('member-id');              
              type = 'User';              
            }  
            
            scope.$apply(function(){
              scope.addEvent({event: 
                {
                //  text: text, 
                 start_at: $(hoverColumns).first().data('date'), 
                 end_at: $(hoverColumns).last().data('date'),
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
}).directive('ginkgoResizeable', function () {
    return function(scope, element, attrs) {
      element.resizable({
        handles: "e",
        grid: scope.gridWidth ,
        resize: function(event, ui) {
          $(this).css('height', 'auto');
        },
        stop: function(event, ui) {
          var range = scope.calculateHoverIndex(ui.helper);
          var allDays = $(this).parents('.month-row').find('.days .day') ;        
          var hoverColumns = $(allDays).slice(range.start - 1, range.end - 1);  
          
          scope.$apply(function(){
            scope.updateEvent({
              event: {              
                id: $(ui.helper).data('event-id'), 
                start_at: $(hoverColumns).first().data('date'), 
                end_at: $(hoverColumns).last().data('date')
               }  
            })
          });  
        }
      });        
    }
}).directive('ginkgoPopover', function ($rootScope, $http, $compile) {
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
               // '<div class="control-group">' + 
               //   '<label class="control-label">Name</label>' + 
               //   '<div class="controls"><input name="text" value="{{ event.text }}"></input></div>' +
               // '</div>' +
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
               var targetOffset = element.parents('.month-row').find('.title').offset();
               $('#calendar_item_editor_singleton').html(compile);
               $('#calendar_item_editor_singleton').show()
                                                   .css('top', targetOffset.top - 55).
                                                    css('left', targetOffset.left + 10 + element.parents('.month-row').find('span.event').width());                                                    
            
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
}).directive('ginkgoTaskPopover', function ($rootScope, $http, $compile) {
  return {
     link: function(scope, element, attrs) {
       attrs.$observe('taskId', function(value) {            
           var task = _.find(scope.tasks, function(e){ return e.id == parseInt(value); })        

           var template = 
           '<div class="popover-content balloon right_side">' +
             '<span class="arrow"></span>' +
             '<form name="eventForm" class="form-horizontal">' +              
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
                  scope.$apply(function(){         
                    var eventFormData = $('#calendar_item_editor_singleton').find('form').serializeObject() ;                                     
                    scope.updateTask({
                      id: task.id,
                      task: {name: eventFormData.text}
                    })
                  });                    
                  $('#calendar_item_editor_singleton').hide();                                      
                })
                e.stopPropagation();                                                                                    
             })
    
        });
     }
  }
});      




