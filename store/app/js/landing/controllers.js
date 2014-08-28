'use strict';

/* Controllers */

angular.module('myApp.controllers', [])

  .controller('MenuCtrl', function($scope, waabuCart) {
      $scope.waabuCart= waabuCart;

  })

  .controller('TestCtrl', function($scope, cart) {
  })

  .controller('LandingCtrl', ['$scope', 'waabuCart', 'productService', function($scope, waabuCart, productService) {
      $scope.nextStep = "#/selectService";

      $scope.productFirst = {serviceId:7, heading:"WebWaab", description:"Your own website. Batteries included.", price:5.00};
      $scope.productSecond = {serviceId:2, heading:"CoreWaab", description:"Your own server. Batteries included.", price: 9.00};

  }]);
