'use strict';

/* Directives */


angular.module('myApp.directives')

  // landing page 
/*
  .directive('waabuLandingHeader', function() {
      return {
         restrict: 'E',
         templateUrl: "landing/res/header.html"
      };
  })
 
  .directive('waabuLandingProduct', ['waabuCart', 'productService', function(waabuCart, $location, productService) {
      return {
         scope: { content: "=content" }, 
         controller: function($scope, waabuCart, $location) {
	   /*if ($scope.content.colour != undefined) { 
            $scope.colour = $scope.content.colour; 
	   } else {
	    $scope.colour = "#3498db";
	   }
            $scope.newItem = function() { waabuCart.newItem($scope.content.serviceId); $location.path("/selectPackage"); };
         },
	link: function(scope, elem, attrs, ctrl) { 
          elem.find("#buttons")[0].style.backgroundColor = scope.content.buttonBackgroundColour;
//          elem.find("#buttons")[0].style.borderColor = scope.content.buttonBorderColour;
          elem.find("#buttons").children()[0].style.backgroundColor = scope.content.buttonColour;
//          elem.find("#buttons").children()[0].style.borderColor = scope.content.buttonBorderColour;
          elem.find("#buttons").children()[1].style.backgroundColor = scope.content.buttonColour;
//          elem.find("#buttons").children()[1].style.borderColor = scope.content.buttonBorderColour;
          //elem.find("#button")[1].style.backgroundColor = scope.content.buttonColour;
	},
         restrict: 'E',
         templateUrl: "landing/res/serviceCol.html"
      };
   }])
   
  .directive('waabuLandingNextStep', function($location) {
      return {
         controller: function($scope, $location) {
            $scope.go = function(path) { $location.path(path); };
         },
         restrict: 'E',
         templateUrl: "landing/res/nextStep.html"
      };
  })
*/
;
