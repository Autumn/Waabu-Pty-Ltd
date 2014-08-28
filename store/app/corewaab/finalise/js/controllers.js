'use strict';

/* Controllers */

angular.module('myApp.controllers')
  .controller('CoreWaabFinaliseCtrl', function($scope, waabuCart, $location) {
      if (JSON.stringify(waabuCart.item) == JSON.stringify({})) {
         $location.path("/coreWaab/select");
      }
  });

