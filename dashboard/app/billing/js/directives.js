'use strict';

angular.module('myApp.directives').
  directive('billingDetails', function() {
    return {
      templateUrl: 'billing/res/details.html',
      restrict: 'E',
      scope: {
        receipt: '=receipt'
      },
      controller: function($scope, billingService) {
      }
    };
  })

  .directive('duePayments', function() {
    return {
      restrict: 'E',
      templateUrl: 'billing/res/duepayments.html'
    }
  });
