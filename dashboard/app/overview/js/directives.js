'use strict';

/* Directives */


angular.module('myApp.directives').
  directive('overviewHeader', function() {
    return {
      templateUrl: 'overview/res/header.html',
      restrict: 'E'    
    };
  }).
  directive('productSummary', function() {
    return {
      templateUrl: 'overview/res/products.html',
      restrict: 'E'    
    };
  });
