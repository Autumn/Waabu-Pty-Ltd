'use strict';

/* Directives */

angular.module('myApp.directives', [])

  .directive('appVersion', ['version', function(version) {
    return function(scope, elm, attrs) {
      elm.text(version);
    };
  }])


  .directive('landingReg', function() {
    return {
      restrict: 'E',
      templateUrl: 'accounts/landing.html'
    }
  })

  .directive('registrationForm', function() {
    return {
      restrict: 'E',
      require: 'RegisterCtrl',
      templateUrl: 'accounts/register.html'
    }
  })

  .directive('loginForm', function() {
    return {
      restrict: 'E',
      require: 'LoginCtrl',
      templateUrl: 'accounts/login.html'
    }
  })

  .directive('waabuLoginDialog', function(accountService) {
    return {
      restrict: 'E',
      templateUrl: "login/dialog.html",
      controller: function($scope) {
      }
    };
  })

  .directive('waabuRegisterDialog', function(accountService) {
    return {
      restrict: 'E',
      templateUrl: "register/dialog.html",
      controller: function($scope) {
      }
    };
  })
  .directive('waabuFooter', function() {
    return {
      restrict: 'E',
      templateUrl: "footer/layout.html"
    };
  })

  .directive('cartItem', function(productService, cartService) {
    return {
      templateUrl: 'checkout/item.html',
      restrict: 'E',
      scope: {
        item: '=item'
      },
      controller: function($scope, cartService) {
        var config = cartService.getItemConfig($scope.item);
        $scope.name = config.name;
        $scope.cpu = config.cpu;
        if ($scope.cpu < 2) { 
          $scope.cpu = $scope.cpu + " CPU"
        } else {
          $scope.cpu = $scope.cpu + " CPUs"
        }
        $scope.ram = config.ram; 
        if ($scope.ram == 512) {
          $scope.ram = $scope.ram + "MB RAM"
        } else {
          $scope.ram = $scope.ram + "GB RAM"
        }
        $scope.storage = config.storage;
        $scope.storagetype = config.storagetype;
        $scope.os = cartService.getOsStr(config.os);
        $scope.price = config.price;

      }
    }
  })

;
