'use strict';

/* Directives */


angular.module('myApp.directives')

  // service select page
 
  .directive('webwaabBox', function(waabuCart, $location, productService) {
      return {
         scope: { content: "=content" },
         controller: function($scope, waabuCart, productService) {
              $scope.title = $scope.content.waabName;
/*            (function() {
              var item = productService.findProductByName($scope.content.waabName);
              if (item.error != "not found") {
                $scope.title = $scope.content.waabName;
                $scope.cpu = item.cpu;
                if ($scope.cpu > 1)
                  $scope.cpu_plural = "s";
                $scope.storage = item.storage;
                $scope.ram = item.ram;
                $scope.storageType = item.storage_type;
                $scope.monthlyPrice = item.price.monthly;
                $scope.yearlyPrice = item.price.yearly;
              }
            })();
            $scope.selectService = function() { 
              waabuCart.newItem(productService.findProductByName($scope.content.waabName)); 
              $location.path("/coreWaab/config");
            };
*/
         },
         link: function(scope, elem, attrs, ctrl) {
//           elem[0].childNodes[0].style.backgroundColor = scope.colour;
          elem.find("#header")[0].style.backgroundColor = scope.content.buttonBackgroundColour;
          elem.find("#buttons")[0].style.backgroundColor = scope.content.buttonBackgroundColour;
          elem.find("#buttons")[0].style.borderColor = scope.content.buttonBorderColour;
          elem.find("#buttons").children()[0].style.backgroundColor = scope.content.buttonColour;
          //elem.find("#buttons").children()[0].style.borderColor = scope.content.buttonBorderColour;

         },
         restrict: 'E',
         templateUrl: "webwaab/res/box.html"
      };
  })
  
  .directive('waabuServiceNextStep', function($location, waabuCart) {
      return {
         
controller: function($scope, $location, waabuCart) {
            $scope.go = function(path) { 
               if (JSON.stringify(waabuCart.item) != JSON.stringify({})) {
                  $location.path(path); 
               }
            };
         },
         restrict: 'E',
         templateUrl: "corewaab/select/res/nextStep.html"
      };
  })
;
