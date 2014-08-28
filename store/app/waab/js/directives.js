'use strict';

/* Directives */


angular.module('myApp.directives')


  // waab service page
  // ------------------------------------------------

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

  // config page directives
  // ------------------------------------------------

  .directive('waabuConfigHeader', function() {
      return {
         restrict: 'E',
         templateUrl: "waab/config/res/header.html"
      };
  })

  .directive('waabuConfigOsSelect', function() {
      return {
         restrict: 'E',
         require: 'WaabConfigCtrl',
         templateUrl: "waab/config/res/os.html"
      };
  })
  .directive('waabuConfigSshConfig', function() {
      return {
         restrict: 'E',
         require: 'WaabConfigCtrl',
         templateUrl: "waab/config/res/ssh.html",
         controller: function($scope) {
         }
      };
  })

  .directive('sshKeyValidator', function() {
    return {
      require: 'ngModel',
      link: function(scope, elem, attrs, ctrl) {
        ctrl.$parsers.unshift(function(viewValue) {
        // validate ssh key
          ctrl.$setValidity('validKey', false);
          return viewValue;
          //ctrl.$setValidity('validKey', false);
          //return undefined;
        })
      }
    }
  })

  .directive('waabuConfigUpgrades', function() {
    return {
      restrict: 'E',
      templateUrl: "waab/config/res/upgrades.html",
      controller: function($scope, cartService, productService) {
        $scope.upgrades = productService.getWaabUpgrades(cartService.getCurrentItemId());
      }
    };
  })
  .directive('waabuConfigUpgradeItem', function() {
    return {
      restrict: 'E',
      templateUrl: "waab/config/res/upgradeitem.html",
      controller: function($scope, cartService) {
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
        $scope.price = $scope.item.prices.monthly;

        $scope.toggleSymbols = function() {
	  if (cartService.itemHasUpgrade($scope.type)) {
	    $scope.toggleLabel = "-";
	  } else {
	    $scope.toggleLabel = "+";
	  }
        }
        $scope.toggleSymbols();

        $scope.toggleUpgrade = function() {
          cartService.toggleItemUpgrade($scope.type);
          $scope.toggleSymbols();
          $scope.updateSummary();
        };
      },
      link: function(scope, elem, attrs) {
        scope.button = elem.find("#upgrade-toggle")[0];
      }  
    }
  })

  .directive('waabuConfigNextStep', function() {
      return {
         controller: function($scope, $location) {
            $scope.go = function(path) { $location.path(path); };
         },
         restrict: 'E',
         transclude: true,
         templateUrl: "waab/config/res/nextStep.html"
      };
  })
;

;
