'use strict';

/* Controllers */

angular.module('myApp.controllers')

  .controller('WebWaabCtrl', function($scope) {

  })
  .controller('WebWaabSelectCtrl', function($scope, productService) {
      $scope.serviceOne = {waabName:"BlogWaab", buttonBackgroundColour: "#74ddf0", buttonColour: "#24bcd8", buttonBorderColour: "#0083ae"};
      $scope.serviceTwo = {waabName:"WebWaab", buttonBackgroundColour: "#b2c2ff", buttonColour: "#7592ff", buttonBorderColour: "#3b5ad1"};
      $scope.serviceThree = {waabName:"CommerceWaab", buttonBackgroundColour: "#74ddf0", buttonColour: "#24bcd8", buttonBorderColour: "#0083ae"};
  });
