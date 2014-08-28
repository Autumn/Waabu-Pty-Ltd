'use strict';


// Declare app level module which depends on filters, and services
angular.module('myApp', [
  'ngRoute',
  'ngAnimate',
  'myApp.filters',
  'myApp.services',
  'myApp.directives',
  'myApp.controllers'
]).

config(['$locationProvider', function($locationProvider) {
$locationProvider.hashPrefix('!');
}])

.config(['$routeProvider', function($routeProvider) {

  $routeProvider.when('/', { 
    templateUrl: 'landing/res/layout.html', 
    title: 'Waabu: Cloud Hosting Provider & Web Hosting...' , 
    description:"Cloud Hosting by Waabu - Enjoy fast, cheap and easy App & Web hosting, powered by our Waabs. Our powerful virtual servers are engineered to bring you hosting power to each person or business",
    resolve: {
      'productService': function(productService) { return productService.promise; }
    }
  });

//  $routeProvider.when('#', {templateUrl: 'landing/res/layout.html', title: 'Waabu: Cloud Hosting Provider & Web Hosting...' , description:"Cloud Hosting by Waabu - Enjoy fast, cheap and easy App & Web hosting, powered by our Waabs. Our powerful virtual servers are engineered to bring you hosting power to each person or business"});

// v2 

  $routeProvider.when('/waabCloudHosting', {templateUrl: 'waab/layout.html', title: 'Waab',
    resolve: {
      'productService': function(productService) { return productService.promise; }
    }
  });

  $routeProvider.when('/waabCloudHosting/configure', {templateUrl: 'waab/config/layout.html', controller: 'WaabConfigCtrl', title:'',
    resolve: {
      'productService': function(productService) { return productService.promise; }
    }
  });

// end v2


  $routeProvider.when('/soldout', {templateUrl: 'partials/soldout.html', controller: '', title: 'Sold out!'});
  $routeProvider.when('/comingsoon', {templateUrl: 'partials/comingsoon.html', controller: '', title: 'Coming Soon'});
  $routeProvider.when('/company', {templateUrl: 'partials/company.html', controller: '', title: 'Our Company'});
  $routeProvider.when('/privacyPolicy', {templateUrl: 'partials/privacy.html', title: 'Privacy Policy'});
  $routeProvider.when('/termsOfService', {templateUrl: 'partials/tos.html', title: 'Terms of Service'});
  $routeProvider.when('/features', {templateUrl: 'features/layout.html', controller: 'FeaturesCtrl', 'title': 'Waabu Features', 'description': 'Your virtual holodeck to hack the planet. Waabu Dashboard.'});
  $routeProvider.when('/login', {templateUrl: 'login/layout.html', controller: 'LoginCtrl', title: 'Login'});
  $routeProvider.when('/register', {templateUrl: 'register/layout.html', controller: 'RegisterCtrl', title: 'Register'});

  $routeProvider.when('/checkout', {templateUrl: 'checkout/layout.html', controller: 'CheckoutCtrl', title: 'Checkout', 
    resolve: {
      'productService': function(productService) { return productService.promise; }
  }});

  $routeProvider.when('/finalised', {templateUrl: 'partials/finalised.html'});

  $routeProvider.when('/features', {templateUrl: 'features/layout.html', 'title': 'Waabu Features', 'description': 'Your virtual holodeck to hack the planet. Waabu Dashboard.'});

//  $routeProvider.when('/webWaab', {templateUrl: 'webwaab/layout.html', controller: 'WebWaabCtrl', title: 'WebWaab'});

//  $routeProvider.when('/coreWaab/select', {templateUrl: 'corewaab/select/res/layout.html', controller: 'CoreWaabSelectCtrl', title:'Select Waab'});
//  $routeProvider.when('/coreWaab/packages', {templateUrl: 'corewaab/packages/res/layout.html', controller: 'CoreWaabPackageSelectCtrl', title:'Select CoreWaab Packages'});
//  $routeProvider.when('/coreWaab/config', {templateUrl: 'corewaab/config/res/layout.html', controller: 'CoreWaabConfigCtrl', title:'CoreWaab Configuration'});
//  $routeProvider.when('/coreWaab/finalise', {templateUrl: 'corewaab/finalise/res/layout.html', controller: 'CoreWaabFinaliseCtrl', title:'Finalise CoreWaab'});
 
//  $routeProvider.when('/webWaab/select', {templateUrl: 'webwaab/choose/layout.html', controller: 'WebWaabSelectCtrl', title: 'Select WebWaab'});

//  $routeProvider.when('/domain/search', {templateUrl: 'domain/search/res/layout.html', controller: 'DomainSearchCtrl', title: 'Domain Availability'});
  $routeProvider.otherwise({redirectTo: '/'});

}])

.run(['$location', '$rootScope', '$templateCache', function($location, $rootScope, $templateCache) {
    $rootScope.$on('$routeChangeSuccess', function (event, current, previous) {
        if (current.$$route != undefined) {
          window.scrollTo(0, 0);
        $rootScope.title = current.$$route.title;
        $rootScope.description = current.$$route.description;
        }
    });
//    $rootScope.$on('$viewContentLoaded', function() {/
//       $templateCache.removeAll();
//    });
}]);
