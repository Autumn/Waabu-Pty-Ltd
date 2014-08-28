'use strict';

/* Controllers */
angular.module('myApp.controllers')

  .controller('MenuCtrl', function($scope, waabuCart) {
      $scope.waabuCart= waabuCart;
  });
