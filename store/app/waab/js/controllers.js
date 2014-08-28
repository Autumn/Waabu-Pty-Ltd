'use strict';

/* Controllers */

angular.module('myApp.controllers')

  .controller('WaabCtrl', function($scope, productService, pingService) {
    pingService.ping("waabs");
  })

  .controller('WaabSelectCtrl', function($scope, productService) {
      $scope.serviceOne = {waabName:"BaseWaab", buttonBackgroundColour: "#74ddf0", buttonColour: "#24bcd8", buttonBorderColour: "#0083ae"};
      $scope.serviceTwo = {waabName:"CoreWaab", buttonBackgroundColour: "#b2c2ff", buttonColour: "#7592ff", buttonBorderColour: "#3b5ad1"};
      $scope.serviceThree = {waabName:"DevWaab", buttonBackgroundColour: "#74ddf0", buttonColour: "#24bcd8", buttonBorderColour: "#0083ae"};
      $scope.serviceFour = {waabName:"CloudWaab", buttonBackgroundColour: "#b2c2ff", buttonColour: "#7592ff", buttonBorderColour: "#3b5ad1"};
      $scope.serviceFive = {waabName:"PowerWaab", buttonBackgroundColour: "#74ddf0", buttonColour: "#24bcd8", buttonBorderColour: "#0083ae"};
  })

  .controller('WaabConfigCtrl', function($scope, cartService, productService, accountService, $location, pingService) {

    if (!cartService.hasItem())
      $location.path("/waabCloudHosting");

    pingService.ping("config");

    $scope.generateSummary = function() {
      // name
      // os
      // upgrades
      // preloading ssh key or not
      // spec summary
      // total cost per month
    };
 
    var getOsStr = function(os) {
      var osStr = os.split("-")
      if (osStr[0] == "ubuntu")
        osStr[0] = "Ubuntu";
      if (osStr[0] == "centos")
        osStr[0] = "CentOS";
      if (osStr[0] == "arch")
        osStr[0] = "Arch Linux";
      if (osStr[0] == "debian")
        osStr[0] = "Debian"
      return osStr[0] + " " + osStr[1] + " " + osStr[2] + " bit";
    } 
 
    $scope.selectOS = function(os) {
      $scope.os = os;
      $scope.osStr = getOsStr(os);
      $scope.osSelected = true;
      $scope.oserror = false;
      cartService.setItemOS(os);
      
      $scope.updateSummary();
    } 

    $scope.setKey = function(key) {

    };

    $scope.checkErrors = function() {
      // remove $scope.error if both os and key are valid
    };
 
    $scope.isValidOs = function() {
      if (typeof $scope.os != 'undefined') {
        $scope.oserror = false;
      } else {
        $scope.oserror = true;
      }
      return $scope.oserror;
    }

    $scope.isValidKey = function() {
      $scope.keyerror = true;
    }
  
    $scope.validItem = function() {
       return !$scope.isValidOs();
      // need os
      // valid ssh key
    };

    $scope.cancelItem = function() {
      cartService.clearItem();
      $location.path("/waabCloudHosting");
    };
 
    $scope.addCompleteItem = function() {
      // check if item valid
      if ($scope.validItem()) {
        $scope.error = false;
        cartService.addItem();
        $location.path("/waabCloudHosting");
      } else {
        $scope.error = true;
      }
    };
  
    $scope.checkout = function() {
      if ($scope.validItem()) {
        $scope.error = false;
        cartService.addItem();
        var checkLogin = accountService.isLoggedIn();
        checkLogin.then(function() {
          if (cartService.validateCart()) {
	    if (accountService.loggedIn) {
	      $location.path("/checkout");
	    } else {
	      $location.search('send', 'checkout');
	      $location.path('/login');
	    }
          } else {
            cartService.destroyCart();
            $location.path("/waabCloudHosting");
            // invalid cart
            // clear whole cart and return to page after warning user
          }
        });
      } else {
        $scope.error = true;
      }
    };
     
    $scope.updateSummary = function() {
      var config = cartService.getItemConfig(cartService.item);
      $scope.itemName = config.name;
      $scope.itemCpu = config.cpu;
      if ($scope.itemCpu < 2) {
        $scope.itemCpu = $scope.itemCpu + " CPU"
      } else {
        $scope.itemCpu = $scope.itemCpu + " CPUs"
      }
      $scope.itemRam = config.ram;
      if ($scope.itemRam == 512) {
        $scope.itemRam = $scope.itemRam + "MB RAM"
      } else {
        $scope.itemRam = $scope.itemRam + "GB RAM"
      }
      $scope.itemStorage = config.storage;
      $scope.itemStorageType = config.storagetype;
      $scope.price = config.price;
      if (typeof config.os != 'undefined')
        $scope.itemOs = getOsStr(config.os);
    }

    $scope.updateSummary();
  });
