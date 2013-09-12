angular.module('ginkgo.filters', []).
  filter('filterByMonth', function() {
  
      function getDadysInMonth(dateObject) {
        var result = [];
        var numberOfDays = moment(dateObject).daysInMonth();
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
    
      function calculateDate(startDate, endDate, date){
        var totalDates = moment(date).daysInMonth();            
        var date1 = new Date(date.getFullYear(), date.getMonth() - 1, 1);          
        var date2 = new Date(date.getFullYear(), date.getMonth() - 1, totalDates);                  
    
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
        
      function getEventStyle(event, date){   
        var totalDates = moment(date).daysInMonth();            
        var dateWidth = (1 / totalDates) * 100;
//        var eventRange =  calculateDate(event.startTime, event.endTime, date);
        var d1 = new Date(event.startTime);
        var d2 = new Date(event.endTime);              
        var daysLength = Math.round((d2 - d1)/ (60 * 60 * 24 * 1000)) + 1;        
        var startDay = parseInt(event.startTime.split("-").pop()) - 1;      
              
          return {left: dateWidth * startDay + "%", 
                  width: daysLength * dateWidth + "%",
                  conflictLeft: "0%",
                  conflictWidth: "0%"
                };
      }  
    
      return function(events, date) {    
        date = new Date(date);    
            
        var date1 = moment(date).date(1).toDate();          
        var date2 = moment(date).add('month', 1).date(0).toDate();                         

        var out = _.filter(events, function(event){                
          var d1 = Date.parse(event.startTime);

          return ((d1 >= date1.getTime()) && (d1 <= date2.getTime()));
        })              
        
        
        for (var i = 0; i < out.length; i++) {
            event = out[i];
      
            var eventStyle = getEventStyle(out[i], date);
            out[i].style = {"margin-left" : eventStyle.left , "width" : eventStyle.width, "background-color": out[i].color};   
            if (out[i].projectId == undefined) {
              out[i].index = _.sortedIndex(events, event , 'position');                          
            }else{
              out[i].index = _.sortedIndex(events, event , 'projectId');              
            }
 
        }  
        return out;
      }  
  })  
