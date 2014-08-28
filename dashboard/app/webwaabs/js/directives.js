'use strict';

/* Directives */


angular.module('myApp.directives').
  directive('webwaabDetails', function() {
    return {
      templateUrl: 'webwaabs/res/details.html', 
      restrict: 'E'
    };
  });
