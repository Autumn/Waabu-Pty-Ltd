'use strict';

/* Directives */


angular.module('myApp.directives').
  directive('feedbackForm', function(feedbackService) {
    return {
      templateUrl: 'feedback/res/form.html',
      restrict: 'E',
      controller: function($scope) {
        $scope.sendFeedback = function() {
          $scope.success = false;
          $scope.error = false;
          if (typeof $scope.feedback == 'undefined' || $scope.feedback == "") {
            $scope.error = true;
            $scope.errormessage = "You haven't written anything! :(";
          } else {
            $scope.success = true;
            feedbackService.sendFeedback($scope.feedback);
          }
        }
      }
    };
  });
