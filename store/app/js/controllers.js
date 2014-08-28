'use strict';

/* Controllers */

angular.module('myApp.controllers', [])

  // landing page controllers

  .controller('LandingCtrl', ['$scope','$location', 'soldOutService', 'productService', 'cartService' , function($scope, $location, soldOutService, productService, cartService) {
  }])

  .controller('FeaturesCtrl', function(pingService) {
    pingService.ping("features");
  }) 

  .controller('CheckoutCtrl', function($scope, $location, $interval, $http, cartService, accountService, checkoutService, checkPaymentService, pingService) {


  // if user is not logged in then redirect to login page

  // if cart is empty at any point, return to main page

  var checkLogin = accountService.isLoggedIn();
  checkLogin.then(function() {
    if (!accountService.loggedIn) {
      $location.search("send", "checkout");
      $location.path("/login");
    }
  });

  if (cartService.cart.length == 0) {
    $location.path("/waabCloudHosting");
  }
  $scope.cart = cartService.cart;
  $scope.cartService = cartService;

  $location.search("send", null);

  pingService.ping("atcheckout");

  $scope.checkPayment = function(id) {
    $scope.paymentListener = $interval(function() {
      checkPaymentService.checkPayment(id).then(function() {
        if (checkPaymentService.state == "pending" || checkPaymentService.state == "approved") {
          $interval.cancel($scope.paymentListener);
          cartService.destroyCart();
          $location.path("/finalised")
        }
      });
    }, 10000);
  };

  $scope.pay = function(type) {

    if (!accountService.loggedIn) {
      $location.search("send", "checkout");
      $location.path("/login");
    }

    var sendPayment;
    if (type == "bitcoin") {
      sendPayment = function() { return checkoutService.bitcoinPayment(); }
    } else if (type == "paypal") {
      $scope.paypalPayment = true;
      $scope.bitcoinPayment = false;
      sendPayment = function() { return checkoutService.paypalPayment(); }
    }
    var paymentPromise = sendPayment();
    if (paymentPromise.error == "empty cart") {
      $location.path("/waabCloudHosting")
    } else if (paymentPromise.error == "invalid cart") {
      $location.path("/waabCloudHosting")
    } else {
      paymentPromise.then(function() {
        if (checkoutService.paymentSent) {
          if (type == "bitcoin") {
            $scope.bitcoinPayment = true;
            $scope.paypalPayment = false;
            $scope.btc_price = checkoutService.paymentData.amount;
            $scope.address = checkoutService.paymentData.address;
            $scope.qr_url = checkoutService.paymentData.qrcode;
            $scope.btc_url = checkoutService.paymentData.url;
            $scope.checkPayment(checkoutService.paymentData.id);
          } else if (type == "paypal") {
            // get redirect url and open new window
            var redirectUrl = checkoutService.paymentData.link;
	    window.open(redirectUrl, 'PaypalWindow');
            // check payment
            $scope.checkPayment(checkoutService.paymentData.id);
          }
        } else {
          // mark session as invalid and log in again
          accountService.logout().then(function() {
            $location.search("send", "checkout");
            $location.path("/login");
          });
        }
      });
    }
  }
  })

  .controller('LoginCtrl', function($scope, accountService, cartService, $location, $interval) {

    $scope.redirectCheckout = false;

    var urlStr = $location.search();

    if (urlStr.send == "checkout") {
      $scope.redirectCheckout = true;
    }

    $scope.register = function() {
      if ($scope.redirectCheckout) {
        $location.search("send", "checkout");
      }
      $location.path("/register");
    };

    $scope.recoverPassword = function() {

    };

    $scope.login = function() {
      $scope.success = false;
      $scope.failure = false;

      if (typeof $scope.email == 'undefined' || $scope.email == "") {
        $scope.loginError = true;
        return;
      }
      if (typeof $scope.password == 'undefined' || $scope.password == "") {
        $scope.loginError = true;
        return;
      }
      var loginPromise = accountService.login($scope.email, $scope.password);
      loginPromise.then(function() {
        if (accountService.success) {
          if ($scope.redirectCheckout) {
            $scope.successcheckout = true;
            $scope.autoRedir = $interval(function() { 
              $scope.stopAutoRedir();
              $location.search('for', null); 
              $location.search('send', null); 
              $location.path('/checkout'); 
            }, 1, 6000);
            $scope.stopAutoRedir = function() {
              $interval.cancel($scope.autoRedir);
            };
            // begin redirect interval
          } else {
            $scope.success = true;
          }
        } else {
          $scope.failure = true;
        }
      });
      // perform login
    }
  })

  .controller('RegisterCtrl', function($scope, cartService, accountService, $location, $interval) {

    $scope.redirectCheckout = false;

    var urlStr = $location.search();

    if (urlStr.send == "checkout") {
      $scope.redirectCheckout = true;
    }

    $scope.login = function() {
      if ($scope.redirectCheckout) {
        $location.search("send", "checkout");
      }
      $location.path("/login");
    };

    $scope.register = function() {
       $scope.nullemailerror = false;
       $scope.nullpassworderror = false;
       $scope.passwordtooshorterror = false;
       $scope.passwordtoolongerror = false;
       $scope.success = false;
       $scope.failure = false;

       if (typeof $scope.email == 'undefined' || $scope.email == "") {
        $scope.nullemailerror = true;
        return;
      }
      if (typeof $scope.password == 'undefined' || $scope.password == "") {
        $scope.nullpassworderror = true;
        return;
      }

      if ($scope.password.length < 8) {
        $scope.passwordtooshorterror = true;
        return;
      } else if ($scope.password.length > 72) {
        $scope.passwordtoolongerror = true; 
        return;
      }

      var registerPromise = accountService.register($scope.email, $scope.password);
      registerPromise.then(function() {
          if (accountService.success) {
            $scope.success = true;
          } else {
            $scope.failure = true;
          }
      });
    }
  })
;
