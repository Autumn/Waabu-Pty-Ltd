'use strict';

/* Controllers */

angular.module('myApp.controllers')

  .controller('CoreWaabPackageSelectCtrl', ['$scope', 'waabuCart', '$location', function($scope, cart, $location) {

      if (JSON.stringify(cart.item) == JSON.stringify({})) {
         alert("you must select a service");
         $location.path("/coreWaab/selectService");

      }
 
      $scope.packageOne = {packageId:1, packageName:"Code", description:"A comprehensive suite of programming languages, ready to go.", icon:"img/png_dialogue.png"};
      $scope.packageTwo = {packageId:2, packageName:"Network", description:"Design, test and penetrate virtual networks, from the safety of your own Waab.", icon:"img/png_forks.png"};
      $scope.packageThree = {packageId:3, packageName:"Cryptocurrency", description:"Build on the blockchain with our cryptocurrency toolchain.", icon:"img/bitcoin_lel.png"};
      $scope.packageFour = {packageId:4, packageName:"System", description: "Inspect your system quickly with standard Linux tools.", icon:"img/png_settings.png"};
      $scope.packageFive = {packageId:5, packageName:"Web", description:"Launch your killer web app quickly with modern web development tools.", icon:"img/png_cloud.png"};
      $scope.packageSix = {packageId:6, packageName:"Social", description:"Control your internet presence with our content management and chat waabapp.", icon:"img/png_peeps.png"};
 }]);

