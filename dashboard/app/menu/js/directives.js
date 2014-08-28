'use strict';

/* Directives */


angular.module('myApp.directives')

  .directive('waabuMenu', function() {
    return {
      restrict: 'E',
      templateUrl: "menu/res/bar.html"
    };
  })

  .directive('waabuMenuLogin', function() {
      return {
         controller: function($scope) {
            $scope.loginToggled = false;
            $scope.toggleLoginWindow = function() {
               var loginBox = $("#waabu-login");
               var rightAlign = $("#waabu-login-position");
               if (!$scope.loginToggled) {
                  loginBox[0].style.right = window.innerWidth - $(rightAlign).offset().left + "px";
                  loginBox[0].style.display = "inline";
                  $scope.loginToggled = true;
               } else {
                  loginBox[0].style.display = "none";
                  $scope.loginToggled = false;
               }
            };
         },
         restrict: 'E',
         templateUrl: "menu/res/login.html"
      };
  })
;
