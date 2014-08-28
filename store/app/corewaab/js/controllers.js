'use strict';

/* Controllers */

angular.module('myApp.controllers')

  .controller('WaabCtrl', function($scope, productService) {

  })
  .controller('WaabSelectCtrl', function($scope, productService) {
      $scope.serviceOne = {waabName:"BaseWaab", buttonBackgroundColour: "#74ddf0", buttonColour: "#24bcd8", buttonBorderColour: "#0083ae"};
      $scope.serviceTwo = {waabName:"CoreWaab", buttonBackgroundColour: "#b2c2ff", buttonColour: "#7592ff", buttonBorderColour: "#3b5ad1"};
      $scope.serviceThree = {waabName:"DevWaab", buttonBackgroundColour: "#74ddf0", buttonColour: "#24bcd8", buttonBorderColour: "#0083ae"};
      $scope.serviceFour = {waabName:"CloudWaab", buttonBackgroundColour: "#b2c2ff", buttonColour: "#7592ff", buttonBorderColour: "#3b5ad1"};
      $scope.serviceFive = {waabName:"PowerWaab", buttonBackgroundColour: "#74ddf0", buttonColour: "#24bcd8", buttonBorderColour: "#0083ae"};
  });
