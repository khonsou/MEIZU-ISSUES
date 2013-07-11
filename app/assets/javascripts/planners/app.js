'use strict';
var Ginkgo = angular.module('Ginkgo', ['ginkgo.services', 'ginkgo.directives', 
                                      'ginkgo.filters', 'ginkgo.resources', 'ng-rails-csrf', 'ngResource']);


var CalendarCtrl = ['$scope', '$resource',  function ($scope, $resource) {
  $scope.daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
       
  $scope.getNumberOfDaysInMonth = function (dateObject) {
      var month = dateObject.getMonth();
      if (month == 1) {
          var leapYear = (new Date(dateObject.getYear(), 1, 29).getDate()) == 29;
          if (leapYear)
              return 29
          else
              return 28;
      } else {
          return $scope.daysPerMonth[month];          
      }
  }
  
  $scope.getDadysInMonth = function(dateObject) {
    var result = [];
    var numberOfDays = $scope.getNumberOfDaysInMonth(dateObject);
    for (var i = 0; i < numberOfDays; i++) {
         result.push({
             year: dateObject.getFullYear(),
             month: dateObject.getMonth(),              
             day: (i + 1 < 10) ? "0" + (i + 1) : (i + 1),
             dateOjbect: new Date(dateObject.getFullYear(), dateObject.getMonth() - 1, i + 1)
         });
    }
    return result;     
  }    
    
  $scope.rows = [0,1,2];    
  $scope.currentMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 1);  
  $scope.days = $scope.getDadysInMonth($scope.currentMonth);  
  
  $scope.events = [];
  $scope.tasks  = [];
  $scope.members  = [];  
          console.log($scope.projectId)
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

    console.log($scope.memberId)
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
    
  $scope.nextMonth = function(){
    $scope.currentMonth = new Date($scope.currentMonth.getFullYear(), $scope.currentMonth.getMonth() + 1, 1);    
    $scope.days = $scope.getDadysInMonth($scope.currentMonth);      
    $scope.getEventLength();      
  };
  
  $scope.prevMonth = function(){
    $scope.currentMonth =  new Date($scope.currentMonth.getFullYear(), $scope.currentMonth.getMonth() - 1, 1);
    $scope.days = $scope.getDadysInMonth($scope.currentMonth);      
    $scope.getEventLength();      
  };
  
  $scope.today = function(){
    $scope.currentMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 1);  
    $scope.days = $scope.getDadysInMonth($scope.currentMonth);      
    $scope.getEventLength();      
  };
    
  $scope.$watch('events', function(newVal) {
    $scope.getEventLength();        
   }, true);
        
  $scope.calculateDate = function(startDate, endDate){
    var totalDates = $scope.getNumberOfDaysInMonth($scope.currentMonth);    
    var date1 = new Date($scope.currentMonth.getFullYear(), $scope.currentMonth.getMonth() - 1, 1);          
    var date2 = new Date($scope.currentMonth.getFullYear(), $scope.currentMonth.getMonth() - 1, totalDates);                  
    
    var startDateInt = Date.parse(startDate);
    var endDateInt = Date.parse(endDate) ;

    var startDay, endDay;        
              
    if( (endDateInt < date1.getTime()) || (startDateInt > date2.getTime()) ){
      return {startDay: 0, endDay: 0};
    }
    
    if (startDateInt < date1) {
      if (endDateInt < date2) {
        startDay = 0;
        endDay = parseInt(endDate.split("-").pop()) ;                
      }else{
        startDay = 1;
        endDay = 31;                
      }
    }else{
      if (endDateInt < date2) {
        startDay = parseInt(startDate.split("-").pop()) - 1;
        endDay = parseInt(endDate.split("-").pop());                
      }else{
        startDay = parseInt(startDate.split("-").pop()) - 1;
        endDay = 31;                
      }
    }
    
    return {startDay: startDay, endDay: endDay};
  }      
        
  $scope.getEventStyle = function(event){   
    var totalDates = $scope.getNumberOfDaysInMonth($scope.currentMonth);
    var dateWidth = (1 / totalDates) * 100;
    var eventRange =  $scope.calculateDate(event.startTime, event.endTime);
              
    if (event.conflictStart == null || event.conflictEnd == null ) {
      return {left: dateWidth * eventRange.startDay + "%", 
              width: (eventRange.endDay - eventRange.startDay) * dateWidth + "%",
              conflictLeft: "0%",
              conflictWidth: "0%"
            };
    }else{

      var conflictRange =  $scope.calculateDate(event.conflictStart, event.conflictEnd);    
      return {left: dateWidth * eventRange.startDay + "%", 
              width: (eventRange.endDay - eventRange.startDay) * dateWidth + "%",
              conflictLeft: dateWidth * conflictRange.startDay + "%",
              conflictWidth: (conflictRange.endDay - conflictRange.startDay) * dateWidth + "%"
            };
    }
  }  
  
  $scope.calculateHoverIndex =  function(ui){
    var totalWidth =  parseInt($('#calendar').css('width'));  
    var totalDates = $scope.getNumberOfDaysInMonth($scope.currentMonth);    
    $scope.gridWidth = totalWidth / totalDates;
        
    var startHoverIndex  =  Math.round(($(ui).offset().left - $('#calendar').offset().left) / $scope.gridWidth) + 1 ;
    var ownerWidth =  parseInt($(ui).css('width'));  
    var widthCount =  Math.round(ownerWidth /  $scope.gridWidth) + 1 ;    
    var endHoverIndex = startHoverIndex + widthCount ;
  
    return {start: startHoverIndex, end: endHoverIndex};
  }
    
  $scope.getEventLength = function(){
    
    for (var i = 0; i < $scope.events.length; i++) {
        event = $scope.events[i];
      
        var eventStyle = $scope.getEventStyle($scope.events[i]);
        $scope.events[i].left = eventStyle.left;
        $scope.events[i].width = eventStyle.width;   
        
        $scope.events[i].conflictLeft = eventStyle.conflictLeft;
        $scope.events[i].conflictWidth = eventStyle.conflictWidth;             
    }  
  }     
  
  $scope.addEvent = function (event) {
//    events.save(event);
    var r =  $resource('/planners/projects/:project_id/events/:id.json', 
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
      var r =  $resource('/planners/projects/:project_id/tasks/:id.json', 
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


var MemberCtrl = function ($scope, $resource) {
  $scope.submitInvite = function(){
    var params =  $('#container-modal').find('form').serializeObject();
    var r =  $resource('/planners/projects/add_member.json', 
                       {},
                       {'save':{method:'POST',isArray:true}});
    r.save(params, function(data){
      $scope.members = data;
      if ($('#container-modal').length > 0) {
        $('#container-modal').modal('hide');
        $('#container-modal').remove();
      }
    });
  }
 
}


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
  
  $('body').tooltip({
    selector: '.tip'
  });


})

