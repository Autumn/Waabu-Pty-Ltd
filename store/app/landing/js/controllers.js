'use strict';

/* Controllers */

angular.module('myApp.controllers')

  .controller('LandingCtrl', ['$scope','$location', 'soldOutService', 'productService', 'cartService' , function($scope, $location, soldOutService, productService, cartService) {
      $scope.nextStep = "#/selectService";

      $scope.productFirst = {borderColour: '#0097c8', buttonBorderColour: '#0083ae', buttonBackgroundColour:'#74ddf0', buttonColour: '#24bcd8', heading:"WebWaab", flavourOne:"Your own website.", flavourTwo: "Batteries included.", price:5.00};
      $scope.productSecond = {borderColour: '#5070ec', buttonBorderColour: '#3b5ad1', buttonBackgroundColour:'#b2c2ff', buttonColour: '#7592ff', heading:"CoreWaab", flavourOne:"Your own server.", flavourTwo: "Batteries included.", price: 9.00};


     $scope.selectService = function(name) {
      console.log(name);
     }
  }]);
