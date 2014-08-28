'use strict';

/* Directives */


angular.module('myApp.directives').
  directive('accountSettings', function(accountService) {
    return {
      templateUrl: 'account/res/settings.html',
      restrict: 'E',
      controller: function($scope) {

        $scope.deleteAccount = function() {
          if ($scope.deleteStart == true) {
            // check password and delete account
            if (typeof $scope.password != 'undefined' && $scope.password != "") {
              $scope.deleteProcess = accountService.deleteAccount($scope.password);
              $scope.deleteProcess.then(function() {
                if (accountService.deleteAccountError) {
                  $scope.deleteFailure = true;
                }
              });
            }
          } else {
            $scope.deleteStart = true;
          }
        }

        $scope.changePassword = function() {
          $scope.changePwError = false;
          $scope.changePwSuccess = false;
          console.log($scope.changePwForm);
          var oldPwInput = $scope.changePwForm.oldpassword;
          var newPwInput = $scope.changePwForm.newpassword;
          var newPwConfInput = $scope.changePwForm.newpasswordconf;

          var changePwError = function(msg) {
            $scope.changePwError = true;
            $scope.changePwErrorMsg = msg;
          }

          if (oldPwInput.$error.required) {
             changePwError("Old password required.");
          } else if (newPwInput.$error.required) {
             changePwError("New password required.");
          } else if (newPwConfInput.$error.required) {
            changePwError("Please confirm new password.");
          } 

          var checkPwLength = function(input, type) {
            if (input.$error.minlength) {
              changePwError("Password must be longer than 8 characters.");
            } else if (input.$error.maxlength) {
              changePwError("Password must be shorter than 72 characters.");
            }
          }

          checkPwLength(newPwConfInput);
          checkPwLength(newPwInput);
          checkPwLength(oldPwInput);
          
          if (newPwInput.$viewValue != newPwConfInput.$viewValue) {
            changePwError("New passwords do not match.");
          }

          $scope.changePwRequest = accountService.changePassword(oldPwInput.$viewValue, newPwInput.$viewValue);
          $scope.changePwRequest.then(function() {
            if (accountService.changeSuccess) {
              $scope.changePwSuccess = true;
            } else {
              $scope.changePwError = true;
              if (accountService.changeFailureReason == "error occured") {
                $scope.changePwErrorMsg = "Error occured. If this keeps happening, please contact support.";
              } else if (accountService.changeFailureReason == "incorrect password") {

                $scope.changePwErrorMsg = "Old password incorrect.";
              }
            }
          });
        }
      }
    };
  });
