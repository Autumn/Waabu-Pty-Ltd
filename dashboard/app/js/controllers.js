'use strict';

/* Controllers */

angular.module('myApp.controllers', []).
  controller('OverviewCtrl', function($scope, vmService) {
    $scope.vms = vmService.vms;
  }).
  controller('WaabCtrl', function($scope, vmService, queryService) {
    $scope.vmLoad = vmService.loadVms();
    $scope.vmLoad.then(function() {$scope.vms = vmService.vms;});
  }).
   controller('WebwaabCtrl', function() {

  }).
  controller('DomainCtrl', function() {

  }).
  controller('BillingCtrl', function($scope, billingService) {
    $scope.billingLoad = billingService.getBilling();
    $scope.billingLoad.then(function() { $scope.payments = billingService.payments; });
  }).
  controller('SupportCtrl', function() {

  }).
  controller('FeedbackCtrl', function() {

  }).
  controller('AccountCtrl', function() {

  });
