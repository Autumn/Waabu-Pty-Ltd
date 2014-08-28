'use strict';

/* Directives */


angular.module('myApp.directives')

  // service select page

  .directive('waabuServiceHeader', function() {
      return {
         restrict: 'E',
         templateUrl: "corewaab/select/res/header.html"
      };
  })
  
  .directive('waabuServiceBox', function($location, productService, soldOutService, cartService) {
      return {
         scope: { content: "=content" },
         controller: function($scope, productService, cartService) {
            (function() {
              var item = productService.getWaabByName($scope.content.waabName);
              if (item.error != "not found") {
                $scope.title = item.name;
                $scope.id = item.id;
                $scope.ram = item.config.ram / 1024.0;
                $scope.cpu = item.config.cpu;
                $scope.storage = item.config.storage;
                $scope.price = item.prices.monthly;
              }
            })();
            $scope.selectService = function() { 
              // waabuCart.newItem(productService.findProductByName($scope.content.waabName)); 
              cartService.newItem(productService.getProductById($scope.id));
              $location.path("/waabCloudHosting/configure");
            };
         },
         link: function(scope, elem, attrs, ctrl) {
           var tile = elem.find(".landing-tile")
           var  header = elem.find(".purple-header")
           var button = elem.find(".purple-button")
           if (scope.content.waabName == "BasicWaab") {
           tile[0].className = "landing-tile dark-blue-tile"
           header[0].className = "dark-blue-tile-header"
           button[0].className = "button dark-blue-button"
           } else if (scope.content.waabName == "CoreWaab") {
           tile[0].className = "landing-tile cyan"
           header[0].className = "cyan-header"
           button[0].className = "button cyan-button"

           } else if (scope.content.waabName == "DevWaab") {
           tile[0].className = "landing-tile pink-tile"
           header[0].className = "pink-tile-header"
           button[0].className = "button pink-button"

           } else if (scope.content.waabName == "CloudWaab") {
           tile[0].className = "landing-tile purple"
           header[0].className = "purple-header"
           button[0].className = "button purple-button"

           } else if (scope.content.waabName == "PowerWaab") {
           tile[0].className = "landing-tile red-tile"
           header[0].className = "red-tile-header"
           button[0].className = "button red-button"
           }
         },
         restrict: 'E',
         templateUrl: "corewaab/select/res/box.html"
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
