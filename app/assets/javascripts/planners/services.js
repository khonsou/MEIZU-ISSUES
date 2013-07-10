'use strict';

/* Services */

angular.module('ginkgo.resources', ['ngResource']).
  factory('Task', function($resource) {
    var Task = $resource('/planners/projects/:project_id/tasks/:id', 
                         {project_id: '@project_id'});
                         
     // Tag.prototype.query = function(cb) {
     //   return Tag.query({},
     //       angular.extend({}, this, {isArray: true}), cb);
     // };                         

    // Tag.prototype.update = function(cb) {
    //   return Tag.update({id: this._id.$oid},
    //       angular.extend({}, this, {_id:undefined}), cb);
    // };
    // 
    // Tag.prototype.destroy = function(cb) {
    //   return Tag.remove({id: this._id.$oid}, cb);
    // };

    return Task;
  });

angular.module('ginkgo.services', []).
    value('version', '0.1').
    value('localStorage', window.localStorage)