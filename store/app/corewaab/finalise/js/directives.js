'use strict';

angular.module('myApp.directives')
   .directive('waabuFinaliseDetails', function(waabuCart, $location, loginService) {
      return {
         controller: function($scope, waabuCart, $location, loginService) {

            $scope.subscribed = false;

            (function() {
              $scope.monthly = waabuCart.getMonthlyPrice();
              $scope.yearly = waabuCart.getYearlyPrice() * 12;
              // add upgrade prices
              for (var i in waabuCart.item.upgrades) {
                 $scope.monthly += waabuCart.getUpgradePrice(waabuCart.item.upgrades[i].type);
                 $scope.yearly += (waabuCart.getUpgradePrice(waabuCart.item.upgrades[i].type) * 12);
              }
            })();

            $scope.selectMonthly = function() {
              waabuCart.setMonthlySubscription();
              $scope.total = $scope.monthly;
              $scope.subscribed = true;
            };

            $scope.selectYearly = function() {
              waabuCart.setYearlySubscription();
              $scope.total = $scope.yearly;
              $scope.subscribed = true;
            };

            $scope.cancelItem = function() {
              waabuCart.cancelItem();
              $location.path('/');
            };

            $scope.addCompleteItem = function() { 
              waabuCart.finaliseItem(); $location.path('/coreWaab/'); 
           };

            $scope.checkout = function() { 
               waabuCart.finaliseItem(); 
               if (!loginService.isLoggedIn()) {
                 $location.search('send', 'checkout');
                 $location.path('/register');
               } else if (loginService.validSession()) {
                 $location.path('/checkout'); 
               } else {
                 loginService.invalidateSession();
                 $location.search('for', 'timeout');
                 $location.search('send', 'checkout');
                 $location.path('/login');
               }
            };


         },
         restrict: 'E',
         templateUrl: "corewaab/finalise/res/details.html"
      };
   })

  .directive('waabuFinalisePayment', function(waabuCart, $location) {
      return {
         restrict: 'E',
         templateUrl: "corewaab/finalise/res/payment.html"
      };
  })
  
  .directive('waabuFinaliseInvoice', function(waabuCart) {
      return {
         controller: function($scope, waabuCart) {
            $scope.waabuCart = waabuCart;
         },
         restrict: 'E',
         templateUrl: "corewaab/finalise/res/invoice.html"
      };
  })
;
