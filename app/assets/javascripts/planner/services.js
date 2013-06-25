'use strict';

/* Services */

angular.module('ginkgo.services', []).
    value('version', '0.1').
    value('localStorage', window.localStorage).
    service('tags', function (localStorage, $rootScope) {
        var self = this;

        self.save = function (tag) {
            if (!tag.hasOwnProperty('id')) {
                var highest = 1;
                for (var i = 0; i < self.tags.length; i++) {
                    if (self.tags[i].id > highest) highest = self.tags[i].id;
                }
                tag.id = ++highest;
            }
            self.tags.push(tag);

            return tag.id;
        };
        self.get = function (id) {
            for (var i = 0; i < self.tags.length; i++) {
                if (self.tags[i].id == id)
                    return self.tags[i];
            }
        };


        function createPersistentProperty(localName, storageName, Type) {
            var json = localStorage[storageName];

            self[localName] = json ? JSON.parse(json) : new Type;

            $rootScope.$watch(
                function () {
                    return self[localName];
                },
                function (value) {
                    if (value) {
                        localStorage[storageName] = JSON.stringify(value);
                    }
                },
                true);

        }
        
        createPersistentProperty('tags', 'ginkgoTags', Array);

        if (self.tags.length === 0) {
            self.save({id:1, text:'设计', done:true});
            self.save({id:2, text:'开发', done:true});            
            self.save({id:3, text:'测试', done:false});
            self.save({id:4, text:'部署', done:false});                        
        }
    }).service('members', function (localStorage, $rootScope) {
        var self = this;

        self.save = function (member) {
            if (!member.hasOwnProperty('id')) {
                var highest = 1;
                for (var i = 0; i < self.members.length; i++) {
                    if (self.members[i].id > highest) highest = self.members[i].id;
                }
                member.id = ++highest;
            }
            self.members.push(member);

            return member.id;
        };
        self.get = function (id) {
            for (var i = 0; i < self.members.length; i++) {
                if (self.members[i].id == id)
                    return self.members[i];
            }
        };


        function createPersistentProperty(localName, storageName, Type) {
            var json = localStorage[storageName];

            self[localName] = json ? JSON.parse(json) : new Type;

            $rootScope.$watch(
                function () {
                    return self[localName];
                },
                function (value) {
                    if (value) {
                        localStorage[storageName] = JSON.stringify(value);
                    }
                },
                true);

        }
        
        createPersistentProperty('members', 'ginkgoMembers', Array);

        if (self.members.length === 0) {
            self.save({id:1, text:'Dave'});
            self.save({id:2, text:'Tony'});            
            self.save({id:3, text:'Nancy'});
            self.save({id:4, text:'Bosh'});                        
        }
    }).service('events', function (localStorage, $rootScope) {
        var self = this;        

        self.save = function (event) {
                      
            var highest = 1;
            for (var i = 0; i < self.events.length; i++) {
                if (self.events[i].id > highest) highest = self.events[i].id;    
                //refresh the order                
                if (self.events[i].order >= event.order) self.events[i].order += 1;                
            }
            event.id = ++highest;
            self.events.push(event);

            return event.id;
        };
        
        self.update = function (event) {            
            var originalEvent = self.get(event.id);
            var originalOrder = originalEvent.order;
            var newOrder = event.order;
            
            //change order
            if ((event.order != undefined) && (originalOrder != newOrder)) {                
              if(originalOrder < newOrder){
                for (var i = 0; i < self.events.length; i++) {                                  
                  if((self.events[i].order > originalOrder) && (self.events[i].order <= newOrder)){
                    self.events[i].order -= 1;
                  }
                }  
              }else{
                for (var i = 0; i < self.events.length; i++) {                                  
                  if((self.events[i].order >= newOrder) && (self.events[i].order < originalOrder)){
                    self.events[i].order += 1;
                  }
                }  
              }                                              
            }  
            
            for (var i = 0; i < self.events.length; i++) {
                if (self.events[i].id == event.id) {                  
                    self.events[i].text = event.text;
                    self.events[i].startTime = event.startTime;
                    self.events[i].endTime = event.endTime;
                    if (event.order != undefined) {
                      self.events[i].order = event.order;                      
                    }                      
                };                
            }
            
            return event.id;
        };

        self.get = function (id) {
            for (var i = 0; i < self.events.length; i++) {
                if (self.events[i].id == id)
                    return self.events[i];
            }
        };
        self.destroy = function (event) {
          var events = self.events;
          for (var i = 0; i < events.length; i++) {  
            if (events[i].id == event.id) {
                events.splice(i, 1);
            }
          }  
          //refresh the order
          for (var i = 0; i < events.length; i++) {                            
            if (events[i].order >= event.order) events[i].order -= 1;                      
          }  
          self.events = events;
        };


        function createPersistentProperty(localName, storageName, Type) {
            var json = localStorage[storageName];

            self[localName] = json ? JSON.parse(json) : new Type;

            $rootScope.$watch(
                function () {
                    return self[localName];
                },
                function (value) {
                    if (value) {
                        localStorage[storageName] = JSON.stringify(value);
                    }
                },
                true);

        }
        
        createPersistentProperty('events', 'ginkgoEvents', Array);

        if (self.events.length === 0) {
            self.save({id:1, text:'设计', type:'tag', startTime: "2013-6-2", endTime: "2013-6-7", eventableId: 1, order: 1 });
            self.save({id:2, text:'开发', type:'tag', startTime: "2013-6-8", endTime: "2013-6-28", eventableId: 2, order: 2});            
            self.save({id:3, text:'Dave', type:'member', startTime: "2013-6-8", endTime: "2013-6-15", eventableId: 1, order: 3});                        
            self.save({id:4, text:'Tony', type:'member', startTime: "2013-6-8", endTime: "2013-6-15", eventableId: 2, order: 4});                                    
        }
    });


