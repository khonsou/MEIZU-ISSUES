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
            // $('.ui-state-highlight').removeClass('ui-state-highlight');          
            // $(hoverColumns).addClass('ui-state-highlight');         
          }
        });
      };              
  }).
  directive('ginkgoDroppable', function () {
    return function(scope, element, attrs) {
          
      element.droppable({
        drop: function(event, ui ){
          // $('.ui-state-highlight').removeClass('ui-state-highlight');          
                      
          var rowIndex = $('.month-row').index($(this).parents(".month-row"));                                
          var text = $.trim($(ui.draggable).text());
          var allDays = $(this).find('.day') ;                            
          var range = scope.calculateHoverIndex(ui.helper);
          
          if($(ui.draggable).hasClass('event')){
            // drag from inner calendar
            var hoverColumns = $(allDays).slice(range.start, range.end);          

            scope.$apply(function(){
              scope.updateEvent({id: $(ui.helper).data('event-id'), 
                                 text: $(ui.helper).text(), 
                                 startTime: $(hoverColumns).first().data('date'), 
                                 endTime: $(hoverColumns).last().data('date'),
                                 order: rowIndex + 2
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
            if($(ui.draggable).data('tag-id') != undefined){
              eventableId = $(ui.draggable).data('tag-id');
              type = 'tag';
            }else{
              eventableId = $(ui.draggable).data('member-id');              
              type = 'member';              
            }  
            
            scope.$apply(function(){
              scope.addEvent({text: text, 
                startTime: $(hoverColumns).first().data('date'), 
                endTime: $(hoverColumns).last().data('date'),
                eventableId: eventableId,
                type: type,
                order: rowIndex + 2 // + 2 because index start from 0
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
          var hoverColumns = $(allDays).slice(range.start - 1, range.end);  
          
          scope.$apply(function(){
            scope.updateEvent({id: $(ui.helper).data('event-id'), 
              text: $.trim($(ui.helper).text()), 
              startTime: $(hoverColumns).first().data('date'), 
              endTime: $(hoverColumns).last().data('date')})
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
               '<div class="control-group">' + 
                 '<label class="control-label">Name</label>' + 
                 '<div class="controls"><input name="text" value="{{ event.text }}"></input></div>' +
               '</div>' +
               '<div class="control-group">' + 
                 '<label class="control-label">Start</label>' + 
                 '<div class="controls"><input name="start" value="{{event.startTime}}"></input></div>' +
               '</div>' +
               '<div class="control-group">' + 
                 '<label class="control-label">End</label>' + 
               '<div class="controls"><input name="end" value="{{event.endTime}}"></input></div>' +
               '</div>' +
             	'<p class="submit">' + 
             		'<input type="submit" value="Save changes" class="btn btn-small btn-success" ng-click="save()">' + 
             		' or <a href="#" class="cancel" data-role="cancel" data-behavior="cancel">Close</a>' + 
                 '<a href="#" class="image delete pull-right" data-behavior="delete">Delete</a>'
             	'</p>' +
             '</form>' +
             '</div>'              
             
             var compile =  $compile(template)(scope);
             element.on('click', function(e){
               var targetOffset = element.find('.title').offset();
               $('#calendar_item_editor_singleton').html(compile);
               $('#calendar_item_editor_singleton').show()
                                                   .css('top', targetOffset.top).
                                                    css('left', targetOffset.left + 50);
                $('#calendar_item_editor_singleton').find('.cancel').on('click', function(){
                  $('#calendar_item_editor_singleton').hide();
                })                                            
                $('#calendar_item_editor_singleton').find('.delete').on('click', function(){
                  if(confirm('Are you sure delete this?')){
                    $('#calendar_item_editor_singleton').hide();                    
                    scope.$apply(function(){
                      scope.destroyEvent(event);
                    });  
                  }
                }) 
                $('#calendar_item_editor_singleton').find('input[type=submit]').on('click', function(){
                  scope.$apply(function(){                                                            
                    var eventFormData = $('#calendar_item_editor_singleton').find('form').serializeObject() ;                                     
                    scope.updateEvent({id: event.id,
                      text: eventFormData.text,
                      startTime: eventFormData.start, 
                      endTime: eventFormData.end
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
});      



