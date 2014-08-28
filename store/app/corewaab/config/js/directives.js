'use strict';

/* Directives */


angular.module('myApp.directives')
  .directive('waabuConfigHeader', function() {
      return {
         restrict: 'E',
         templateUrl: "corewaab/config/res/header.html"
      };
  })
  
  .directive('waabuConfigOsSelect', function() {
      return {
         restrict: 'E',
         require: 'CoreWaabConfigCtrl',
         templateUrl: "corewaab/config/res/os.html"
      };
  })
  
  .directive('waabuConfigSshConfig', function() {
      return {
         restrict: 'E',
         require: 'CoreWaabConfigCtrl',
         templateUrl: "corewaab/config/res/ssh.html",
         controller: function($scope) {
         }
      };
  })
  
  .directive('waabuConfigUpgrades', function() {
    return {
      restrict: 'E', 
      templateUrl: "corewaab/config/res/upgrades.html",
      controller: function($scope, cartService, productService) {
        //$scope.upgrades = productService.findProductByName(waabuCart.item.name).upgrades;
        // get upgrades of product
      }
    };
  })

  .directive('waabuConfigUpgradeItem', function() {
    return {
      restrict: 'E',
      templateUrl: "corewaab/config/res/upgradeitem.html",
      controller: function($scope, waabuCart) {


        $scope.type = $scope.item.type;
          
        if ($scope.type == "hdd") {
        $scope.quantity = $scope.item.quantity + "GB"
        $scope.description = "Replace your SSD with a high capacity hard drive.";
        } else if ($scope.type == "ram") {

          $scope.description = "Beef up your Waab with extra memory.";
          $scope.quantity = "+" + $scope.item.quantity + "MB";
        } else if ($scope.type == "cpu") {
          $scope.description = "Add more cores to your Waab for faster processing.";
          $scope.quantity = "+" + $scope.item.quantity ;
        }

        $scope.price = $scope.item.price;


        if (waabuCart.hasUpgrade($scope.type)) {
          $scope.added = true;
          $scope.toggleLabel = "-";
        } else {
          $scope.added = false;
          $scope.toggleLabel = "+";
        }
                $scope.toggleUpgrade = function() {
          if ($scope.added) {
            waabuCart.removeUpgrade($scope.type);
            $scope.added = false;
            $scope.toggleLabel = "+";
          } else {
            waabuCart.addUpgrade($scope.type); 
            $scope.added = true;
            $scope.toggleLabel = "-";
          }
        };
      },
      link: function(scope, elem, attrs) {
        scope.button = elem.find("#upgrade-toggle")[0];
      }
    };
  })  

  .directive('waabuConfigNextStep', function() {
      return {
         controller: function($scope, $location) {
            $scope.go = function(path) { $location.path(path); };
         },
         restrict: 'E',
         transclude: true,
         templateUrl: "corewaab/config/res/nextStep.html"
      };
  })
;
