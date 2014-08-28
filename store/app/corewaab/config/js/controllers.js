'use strict';

angular.module('myApp.controllers')

  .controller('CoreWaabConfigCtrl', function($scope, waabuCart, $location, validationService) {
    if (JSON.stringify(waabuCart.item) == JSON.stringify({})) {
      $location.path("/coreWaab");
    }
 
    $scope.validOS = false;
    $scope.validKey = true;
    $scope.keyerror = false ;
    $scope.oserror = false;

    $scope.error = false;

    $scope.selected = "";
    $scope.osSelected = false;

    $scope.selectOS = function(os) {
      waabuCart.selectOS(os);
      var osStr = os.split("-")
      if (osStr[0] == "ubuntu")
        osStr[0] = "Ubuntu";
      if (osStr[0] == "centos")
        osStr[0] = "CentOS";
      if (osStr[0] == "arch")
        osStr[0] = "Arch Linux";
      if (osStr[0] == "debian")
        osStr[0] = "Debian"
      $scope.os = osStr[0] + " " + osStr[1] + " " + osStr[2] + " bit";
      $scope.selected = os;
      $scope.osSelected = true;
      $scope.validOS = true;
    };

    $scope.verifySSHKey = function(key) {
      console.log(key);
      if (key == "") {
        $scope.validKey = true;
        return true;
      }
        if (validationService.validateSSHKey(key)) {
          waabuCart.setSSHKey(key);
          $scope.validKey = true;
          return true;
        }
        $scope.validKey = false;
        return false;
    }

    $scope.verifySettings = function() {
        $scope.error = false;
        $scope.keyerror = false;
        $scope.oserror = false;
        console.log($scope.sshkey);

      if ($scope.sshkey != undefined) {
// loading spinner
         $scope.verifySSHKey($scope.sshkey);
      }
      if ($scope.validKey && $scope.validOS) {  
        $scope.error = false;
        $scope.keyerror = false;
        $scope.oserror = false;
        $location.path("/coreWaab/finalise");   
      } else {
        // set errors
        $scope.error = true;
        if (!$scope.validKey) {
          $scope.keyerror = true;
        }
        if (!$scope.validOS) {
          $scope.oserror = true;
        }
      }   
    };
  }) 
  ;

