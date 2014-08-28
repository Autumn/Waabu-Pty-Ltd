'use strict';

/* Directives */


angular.module('myApp.directives')

  .directive('waabuDomainSearch', function() {
      return {
         controller: function($scope) {
           $scope.detailsentered = true;
           $scope.available = true;
           $scope.tlds = [{tld:"com"}, {tld:"net"}, {tld:"info"}, {tld:"me"}, {tld:"org"}, {tld:"in"}, {tld:"co.in"}, {tld:"net.in"}, {tld:"in.net"}];
           $scope.phonecodes = phonecodes;
           $scope.countries = countries;
           $scope.test = function() {
             console.log($scope.tlds);
           };
         }, 
         restrict: 'E',
         templateUrl: "domain/search/res/search.html"
      };
  })
;
