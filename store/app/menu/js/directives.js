'use strict';

/* Directives */


angular.module('myApp.directives')

  .directive('waabuMenu', function() {
    return {
      restrict: 'E',
      templateUrl: "menu/res/bar.html"
    };
  });
/*
  .directive('waabuMenuProgress', function(waabuCart) {
      return {
         controller: function($scope, waabuCart) {
            $scope.progressToggled = false;
            $scope.toggleProgressWindow = function() {
               var progressBox = $("#waabu-progress");
               var rightAlign = $("#waabu-progress-position");
               if (!$scope.progressToggled) {
                  progressBox[0].style.right = window.innerWidth - $(rightAlign).offset().left + "px";
                  progressBox[0].style.display = "inline";
                  $scope.progressToggled = true;
               } else {
                  progressBox[0].style.display = "none";
                  $scope.progressToggled = false;
               }
            }
         },
         restrict: 'E',
         templateUrl: "menu/res/progress.html"
      };
  })

  .directive('waabuMenuCart', function(waabuCart) {
      return {
         controller: function($scope, waabuCart) {
            $scope.cart = waabuCart.cart;
            $scope.cartToggled = false;
            $scope.toggleCartWindow = function() {
               var cartBox = $("#waabu-cart");
               var rightAlign = $("#waabu-cart-position");
               if (!$scope.cartToggled) {
                  cartBox[0].style.right = window.innerWidth - $(rightAlign).offset().left + "px";
                  cartBox[0].style.display = "inline";
                  $scope.cartToggled = true;
               } else {
                  cartBox[0].style.display = "none";
                  $scope.cartToggled= false;
               }
            }
         },
         restrict: 'E',
         templateUrl: "menu/res/cart.html"
      };
  })

  .directive('waabuMenuLogin', function() {
      return {
         controller: function($scope) {
            $scope.loginToggled = false;
            $scope.toggleLoginWindow = function() {
               var loginBox = $("#waabu-login");
               var rightAlign = $("#waabu-login-position");
               if (!$scope.loginToggled) {
                  loginBox[0].style.right = window.innerWidth - $(rightAlign).offset().left + "px";
                  loginBox[0].style.display = "inline";
                  $scope.loginToggled = true;
               } else {
                  loginBox[0].style.display = "none";
                  $scope.loginToggled = false;
               }
            };
         },
         restrict: 'E',
         templateUrl: "menu/res/login.html"
      };
  })
;
*/
