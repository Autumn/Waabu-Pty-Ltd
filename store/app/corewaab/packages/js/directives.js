'use strict';

angular.module('myApp.directives')
  .directive('waabuPackageHeader', function() {
      return {
         restrict: 'E',
         templateUrl: "corewaab/packages/res/header.html"
      };
  })
  
  .directive('waabuPackageBox', function(waabuCart) {
      return {
         scope: { 
           content: "=content",
          },
         controller: function($scope, waabuCart) {

            $scope.buttonState = "Select";
            $scope.toggleButtonState = function() {
              if ($scope.buttonState == "Select") {
                $scope.buttonState = "Deselect";
                $scope.button.style.backgroundColor = "#fff";
              } else {
                $scope.buttonState = "Select";

                $scope.button.style.backgroundColor = "";
              }
            };

            $scope.selectPackage = function() { 
              waabuCart.togglePackage($scope.content.packageId); 
              $scope.toggleButtonState();
           }; 
         },
         link: function(scope, elem, attrs) {
           console.log(elem);
           scope.button = elem.find("#package-button")[0];
           console.log(scope.button);
         },
         restrict: 'E',
         templateUrl: "corewaab/packages/res/box.html"
      };
  })
  
  .directive('waabuPackageNextStep', function() {
      return {
         controller: function($scope, $location) {
            $scope.go = function(path) { $location.path(path); };
         },
         restrict: 'E',
         templateUrl: "corewaab/packages/res/nextStep.html"
      };
  }); 
