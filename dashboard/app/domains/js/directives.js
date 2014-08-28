'use strict';

/* Directives */


angular.module('myApp.directives').
  directive('domainDetails', function() {
    return {
      templateUrl: 'domains/res/details.html', 
      restrict: 'E'
    };
  });
