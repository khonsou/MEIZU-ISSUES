'use strict';
var Ginkgo = angular.module('Ginkgo', ['ginkgo.services', 'ginkgo.directives', 
                                      'ginkgo.filters', 'ginkgo.resources', 'ng-rails-csrf', 'ngResource']);


var CalendarCtrl = ['$scope', '$resource', '$filter', function ($scope, $resource, $filter) {
                   
  $scope.currentMonth = new Date();              
  
  $scope.events = [];
  $scope.tasks  = [];
  $scope.members  = [];  

  if ($scope.projectId != 0 ) {
    var r = $resource('/planners/projects/:id.json', 
                           {id: $scope.projectId},
                           {'query':{method:'GET'}});
    r.query(function(data){
      $scope.events = data.events;
      $scope.tasks = data.tasks;
      $scope.members = data.members;          
    });       
  }else if($scope.memberId){

    var r = $resource('/planners/members/:id.json', 
                           {id: $scope.memberId},
                           {'query':{method:'GET'}});
    $scope.events  = [];                          
    r.query(function(data){
      _.each(data.events_groups, function(iterator){
        $scope.events = _.union($scope.events, iterator.events);
      })
    });       
  }    
    
  // $scope.$watch('events', function(newVal, oldVal) {   
  //     $scope.eventsSize();     
  //  }, true);        
  
  $scope.calculateHoverIndex =  function(ui, holder, date){
    var totalWidth =  $('#calendar').outerWidth();  
    var totalDates = moment(date).daysInMonth();    
    $scope.gridWidth = totalWidth / totalDates;
    
    var startHoverIndex;
    if ($(holder).offset().left > $(ui).offset().left) {
      startHoverIndex  =  Math.round(($(ui).offset().left - $(holder).parents('li').offset().left) / $scope.gridWidth) + 1 ;      
    }else{
      startHoverIndex  =  Math.round(($(ui).offset().left - $(holder).offset().left) / $scope.gridWidth) + 1 ;      
    }

    var widthCount =  Math.round($(ui).outerWidth() /  $scope.gridWidth)  ;    
    var endHoverIndex = startHoverIndex + widthCount ;
  
    return {start: startHoverIndex, end: endHoverIndex};
  }
   
  
  $scope.addEvent = function (event) {
    var r =  $resource('/planners/projects/:project_id/events.json', 
                       {project_id: $scope.projectId},
                       {'save':{method:'POST',isArray:true}});
    r.save({project_id: $scope.projectId}, event, function(data){
       $scope.events = data;      
    });
  }
  
  $scope.destroyEvent = function (event) {
    var r =  $resource('/planners/events/:id.json', 
                       {},
                       {'remove':{method:'DELETE',isArray:true}});
    r.remove({id: event.id}, function(data){
       $scope.events = data;      
    });

  }

    
  $scope.updateEvent = function (params) {
    //params is event: {id: xxx}
    var r =  $resource('/planners/events/:id.json', 
                       {},
                       {'update':{method:'PUT',isArray:true}});
    r.update({id: params.event.id}, params, function(data){
       $scope.events = data;      
    });

  }
  
  $scope.insertFakeEvent = function (event) {
    $scope.events.push(event)
  }
  
  $scope.destroyFakeEvent = function () {
    var event = _.findWhere($scope.events, {fake: true});
    if (event != undefined) {
      var index = $scope.events.indexOf(event);
      $scope.events.splice(index,1);      
    }

  }
  
  $scope.hasEventByTagId = function(tagId){
    if(_.findWhere($scope.events, {tagId: tagId}) == undefined){
      return false;      
    }else{
      return true
    }    
  }
  
}];


var TaskCtrl = ['$scope', '$resource', function ($scope, $resource) {

  $scope.addTask = function () {
    if($scope.task == undefined){
    }else{
      var r =  $resource('/planners/projects/:project_id/tasks.json', 
                         {project_id: $scope.projectId},
                         {'save':{method:'POST',isArray:true}});
      r.save({project_id: $scope.projectId}, $scope.task, function(data){
         $scope.tasks = data;      
      });
      $scope.task.text = '';     
    }
  }
  
  $scope.destroyTask = function (task) {
    var r =  $resource('/planners/tasks/:id.json', 
                       {},
                       {'remove':{method:'DELETE'}});
    r.remove({id: task.id}, function(data){
      $scope.$parent.events = data.events;
      $scope.tasks = data.tasks;
    });
  }
  
  $scope.updateTask = function (task) {
    var r =  $resource('/planners/tasks/:id.json', 
                       {},
                       {'update':{method:'PUT'}});
    r.update({id: task.id}, task, function(data){
      $scope.$parent.events = data.events;
      $scope.tasks = data.tasks;
    });
  }
}];


var MemberCtrl =  ['$scope', '$resource', function($scope, $resource) {
  $scope.submitInvite = function(projectId){
    var params =  $('#container-modal').find('form').serializeObject();
    var r =  $resource('/planners/projects/add_member.json', 
                       {project_id: projectId},
                       {'save':{method:'POST',isArray:true}});
    r.save(params, function(data){
      $scope.members = data;
      if ($('#container-modal').length > 0) {
        $('#container-modal').modal('hide');
        $('#container-modal').remove();
      }
    });
  }
  
  $scope.destroyMember = function (member) {
    var r =  $resource('/planners/members/:id.json', 
                       {},
                       {'remove':{method:'DELETE'}});
    r.remove({id: member.id}, function(data){
      $scope.$parent.events = data.events;
      $scope.members = data.members;
    });
  }
}];


//-------------------begin of jquery------------------
$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};

$(document).ready(function () {
  
  $('#wrap').click(function(){
    $('#calendar_item_editor_singleton').hide();
    $('input[rel=date]').datepicker('destroy');                      
  })
  
  $('#calendar_item_editor_singleton').on('click', function(e){
    e.stopPropagation();
  })    
  $('#ui-datepicker-div').on('click', function(e){
    e.stopPropagation();
  })    
  
  
  
  $('body').tooltip({
    selector: '.tip'
  });
  
  var sly ;
  if($('#frame')[0] != undefined){
    sly = new Sly('#frame', {
      horizontal: 1,
      mouseDragging: 0,
      touchDragging: 1 ,
      itemNav: 0,
      smart: 0,
      dragHandle: 1,
  		dynamicHandle: 1,
    	speed: 300,
      startAt: 4250 + new Date().getDate() / 2 * 25, //居中
      releaseSwing: 1,
    	elasticBounds: 0,
      scrollBar: $('.scrollbar'),
      clickBar: 1,
      scrollBy: 0 ,
      keyboardNavBy: 'items'
    }).init();
  }

  

})

