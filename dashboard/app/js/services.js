'use strict';

/* Services */


// Demonstrate how to register services
// In this case it is a simple value service.
angular.module('myApp.services', []).
  value('version', '0.1')

  .factory('vmService', function($http, sessionEndService) {
    var service = {};

    var getVMs = function(data, status, headers, config) {
      if (data.error == "not logged in")
        sessionEndService.logout();
       console.log(data);
      service.vms = data.vms;
    };
 
    service.loadVms = function() {
      return $http.get('/vms').success(getVMs);
    };

    
    // list of all VMs client has access to
 
    return service;
  })

  .factory('queryService', function($http, sessionEndService) {
    var service = {};

    // given a VM, returns stats
    service.id = "386ef79b-7edb-f015-f58e-5e5c2123cef6";

    service.getData = function(id, type, callback) {
      if (typeof id == 'undefined') return;
 
      $http.post('/query', "", {params:{"id":id,"type":type}}).success(function(data, status, headers, config) {
        if (data.error != "not logged in")
          callback(data, status, headers, config);
        else
          sessionEndService.logout();
      });
    }

   service.sendCommand = function(id, type, callback) {
     $http.post('/command', "", {params:{"id":id, "type":type}}).success(callback);
   }

    return service;
  })

  .factory('supportService', function($http) {
    var service = {};
    service.sendTicket = function(subject, body) {
      $http.post('/support', "", {params:{"subject":subject,"body":body}});
    };
    return service;
  })

  .factory('feedbackService', function($http) {
    var service = {};
    service.sendFeedback = function(body) {
      $http.post('/feedback', "", {params:{"body":body}});
    };

    return service;
  })

  .factory('billingService', function($http, sessionEndService) {
    var service = {};

    var loadCallback = function(data, status, headers, config) {
      if (data.error == "not logged in") 
        sessionEndService.logout();
      service.payments = data;
      console.log(data);
      console.log(service.payments);
    };

    service.getBilling = function() {
      return $http.get('/billing').success(loadCallback);
    }

    return service;
  })

  .factory('accountService', function($http, sessionEndService) {
    var service = {};

    service.changePassword = function(oldpw, newpw) {
      var callback = function(data, status, headers, config) {
        if (data.error == "not logged in")
          sessionEndService.logout();
        if (data.error == "incorrect old pw") {
          service.changeSuccess = false;
          service.changeFailureReason = "incorrect password";
        } else if (data.error == "error occured") {
          service.changeSuccess = false;
          service.changeFailureReason = "error occured";
        } else if (data.error == 'none') {
          service.changeSuccess = true;
        }
      }
      return $http.post('/changepw', "", {params:{old:oldpw, new:newpw}}).success(callback);
    }

    service.deleteAccount = function(password) {
      var callback = function(data, status, headers, config) {
        if (data.error == "incorrect pw") {
           service.deleteAccountError = true;
        } else if (data.error == "none") {
          sessionEndService.goodbye();
        } else if (data.error == "not logged in") {
          sessionEndService.logout();
        }  
      };
      return $http.post('/deleteaccount', "", {params:{pw:password}}).success(callback);
    }
    return service;
  })

  .factory('sessionEndService', function() {
    var service = {};
    service.logout = function() {
      window.location.href = "/sessionerror";
    };
    service.goodbye = function() {
      window.location.href = "/goodbye";
    };
    return service;
  });
;
