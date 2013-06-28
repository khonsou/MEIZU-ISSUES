'use strict';
var Ginkgo = angular.module('Ginkgo', ['ginkgo.services', 'ginkgo.directives', 
                                      'ginkgo.filters', 'ginkgo.resources', 'ng-rails-csrf', 'ngResource']);


var CalendarCtrl = function ($scope, events) {
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
             day: (i + 1 < 10) ? "0" + (i + 1) : (i + 1)
         });
    }
    return result;     
  }    
    
  $scope.rows = [0,1,2];    
  $scope.currentMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 1);  
  $scope.days = $scope.getDadysInMonth($scope.currentMonth);  
  $scope.events = events.events;
  
  $scope.nextMonth = function(){
    $scope.currentMonth = new Date($scope.currentMonth.getFullYear(), $scope.currentMonth.getMonth() + 1, 1);    
    $scope.days = $scope.getDadysInMonth($scope.currentMonth);      
  };
  
  $scope.prevMonth = function(){
    $scope.currentMonth =  new Date($scope.currentMonth.getFullYear(), $scope.currentMonth.getMonth() - 1, 1);
    $scope.days = $scope.getDadysInMonth($scope.currentMonth);      
  };
    
  $scope.$watch('events', function(newVal) {
    $scope.getEventLength();        
   }, true);
      
  var totalDates = $scope.getNumberOfDaysInMonth($scope.currentMonth);
  var dateWidth = (1 / totalDates) * 100;
  
  $scope.getEventStyle = function(event){        
    // var startMonth = parseInt(event.startTime.split("-")[1]);   
    // if () {
    //   
    // }
    var startDay = parseInt(event.startTime.split("-").pop()) - 1;
    var endDay = parseInt(event.endTime.split("-").pop()) - 1;        
    return {left: dateWidth * startDay + "%", width: (endDay - startDay) * dateWidth + "%"};
  }  
  
  var totalWidth =  parseInt($('#calendar').css('width'));  
  $scope.gridWidth = totalWidth / totalDates;

  $scope.calculateHoverIndex =  function(ui){
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

        if(event.timeFrames != undefined){
          for (var j = 0; j < event.timeFrames.length; j++) {
              var timeFrameStyle = $scope.getEventStyle(event.timeFrames[j]);  
              $scope.events[i].timeFrames[j].left = timeFrameStyle.left;
              $scope.events[i].timeFrames[j].width = timeFrameStyle.width;                     
          }             
        }
        
    }  
  }     
  
  $scope.addEvent = function (event) {
    var id = events.save(event);
  }
  
  $scope.destroyEvent = function (event) {
    events.destroy(event);
  }
    
  $scope.updateEvent = function (event) {
    console.log(event)
    var id = events.update(event);
  }
  
  $scope.addTimeFrame = function (timeFrame) {
    events.saveTimeFrame(timeFrame)
  }
    
  $scope.updateTimeFrame = function (timeFrame) {
    events.updateTimeFrame(timeFrame)
  }
  
  $scope.hasTimeFrame = function(event, memberId){    
    if(_.findWhere(event.timeFrames, {memberId: memberId}) == undefined){
      return false;      
    }else{
      return true
    }    
  }
  
  $scope.hasEventByTagId = function(tagId){
    if(_.findWhere($scope.events, {tagId: tagId}) == undefined){
      return false;      
    }else{
      return true
    }    
  }
}


var TaskCtrl = function ($scope, $resource, Task) {


  //$scope.tags = Tag.query({project_id: $scope.projectId});
  var r = $resource('/planners/projects/:project_id/tasks/:id', 
                         {project_id: $scope.projectId},
                         {'query':{method:'GET',isArray:true}});
   r.query(function(data){
     $scope.tasks = data;
   });

        
  $scope.addTask = function () {
//    var id = tags.save({text: $scope.tagText, done: false});
    var r =  $resource('/planners/projects/:project_id/tasks/:id', 
                       {project_id: $scope.projectId},
                       {'save':{method:'POST',isArray:true}});
    r.save({project_id: $scope.projectId}, $scope.task, function(data){
       $scope.tasks = data;      
    });
    $scope.task.text = '';    
  }
  
  $scope.destroyTask = function (task) {
    var r =  $resource('/planners/tasks/:id', 
                       {},
                       {'remove':{method:'DELETE',isArray:true}});
    r.remove({id: task.id}, function(data){
       $scope.tasks = data;      
    });
  }
  
  $scope.updateTask = function (task) {
    var r =  $resource('/planners/tasks/:id', 
                       {},
                       {'update':{method:'PUT',isArray:true}});
    r.update({id: task.id}, task, function(data){
       $scope.tasks = data;      
    });
  }
}


var MemberCtrl = function ($scope, members) {
  $scope.members = members.members;
    
}

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
  $('body').click(function(){
    $('#calendar_item_editor_singleton').hide();
  })

  $('#calendar_item_editor_singleton').on('click', function(e){
    e.stopPropagation();
  })    

})

