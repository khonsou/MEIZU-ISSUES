angular.module('ginkgo.filters', []).
  filter('filterByMonth', function() {
      return function(events, date) {        
        date1 = new Date(date.getFullYear(), date.getMonth() - 1, 1);          
        date2 = new Date(date.getFullYear(), date.getMonth() - 1, 30);                  
        var out = _.filter(events, function(event){                
          var d1 = Date.parse(event.startTime);
          var d2 = Date.parse(event.endTime) ;
                    
          return !( (d2 < date1.getTime()) || (d1 > date2.getTime()) );
        })        
        return out;
      }  
  })  
