'use strict';

// Declare app level module which depends on filters, and services
angular.module('myApp', [
  'ngRoute',
  'myApp.filters',
  'myApp.services',
  'myApp.directives',
  'myApp.controllers',
  'ngAnimate'
]).
config(['$routeProvider', function($routeProvider) {
  $routeProvider.
    when('/', {
      redirectTo: '/waabs'
    }).
    when('/waabs', {
      templateUrl: 'waabs/res/layout.html',
      controller: 'WaabCtrl'
    }).
    when('/webwaabs', {
      templateUrl: 'webwaabs/res/layout.html',
      controller: 'WebwaabCtrl'
    }).
    when('/domains', {
      templateUrl: 'domains/res/layout.html',
      controller: 'DomainCtrl'
    }).
    when('/account', {
      templateUrl: 'account/res/layout.html',
      controller: 'AccountCtrl'
    }).
    when('/billing', {
      templateUrl: 'billing/res/layout.html',
      controller: 'BillingCtrl'
    }).
//    when('/support', {
//      templateUrl: 'support/res/layout.html',
//      controller: 'SupportCtrl'
//    }).
//    when('/feedback', {
//      templateUrl: 'feedback/res/layout.html',
//      controller: 'FeedbackCtrl'
//    }).

    otherwise({
      redirectTo: '/waabs'
    });
}]);
