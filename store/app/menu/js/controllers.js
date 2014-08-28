'use strict';

/* Controllers */
angular.module('myApp.controllers')

  .controller('MenuCtrl', function($scope, cartService, $location) {
      $scope.cartService = cartService;
      $scope.cart = cartService.cart;

      $scope.deleteItem = function(i) {
        $scope.cartService.deleteItem(i);
      }

      $scope.sendToCheckout = function() {
        $location.search('send', 'checkout');
        $location.path('/checkout');
      };

  });
