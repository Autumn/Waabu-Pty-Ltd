'use strict';

/* Directives */


angular.module('myApp.directives').
  directive('supportTicket', function(supportService) {
    return {
      templateUrl: 'support/res/ticket.html',
      restrict: 'E',
      controller: function($scope) {
        $scope.sendTicket = function() {
          
            $scope.error = false;
            $scope.success = false;
          if (typeof $scope.subject == 'undefined' || typeof $scope.body == 'undefined') {
            $scope.error = true;
            $scope.errormessage = "You haven't entered anything!";
          } else if ($scope.subject == '' || $scope.body == '') {
            $scope.error = true;
            $scope.errormessage = "Please fill in both the subject and body.";
          } else {
            $scope.error = false;
            $scope.success = true ;
            supportService.sendTicket($scope.subject, $scope.body);
          }
        };
      }
    };
  });
