angular.module('ginkgo.filters', []).
  filter('filterByMonth', function() {
      return function(events, date) {        
          var out = _.filter(events, function(event){
          var startYear = parseInt(event.startTime.split("-")[0]);
          var startMonth = parseInt(event.startTime.split("-")[1]);
          
          var endYear = parseInt(event.endTime.split("-")[0]);
          var endMonth = parseInt(event.endTime.split("-")[1]);          
          
          return ((date.getFullYear() == startYear) && (date.getMonth() == startMonth)) || ((date.getFullYear() == endYear) && (date.getMonth() == endMonth)) ;         
          
          var d1 = Date.parse(event.startTime);
          var d2 = Date.parse(event.endTime) ;
          
          return !( (d2 < date.addMonths(-1)) || (d1 > date) );
        })        
        return out;
      }  
  })  
