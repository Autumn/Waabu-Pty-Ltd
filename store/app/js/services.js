'use strict';

/* Services */


// Demonstrate how to register services
// In this case it is a simple value service.
angular.module('myApp.services', []).
  value('version', '0.1')

  .factory('cartService', function(productService) {
    var service;
    var storage = window.localStorage;

 
    var saveCart = function() {
      storage.cart = JSON.stringify(service);
    }

    var initialise = function() {
      if (storage.cart) {
	service = JSON.parse(storage.cart);
        // validate cart
      } else {
	service = {};
	service.cart = [];
	service.item = {};
	saveCart();
      }
    }
    initialise();

    service.validateCart = function() {
      for (var i in service.cart) {
        var item = service.cart[i]
        var product = productService.getProductById(item.id);
        if (typeof product.error != 'undefined')
          return false;

        // check valid os
        var upgrades = productService.getWaabUpgrades(item.id);
        for (var type in upgrades) {
          if (typeof item.options.upgrades[type] == 'undefined')
            return false;
        }
      }
      return true;
    }

    service.cartSize = function() {
      return service.cart.length;
    }

    service.destroyCart = function() {
      service.cart = [];
      service.item = {};
      saveCart();
    }


    service.hasItem = function() {
      if (JSON.stringify({})==JSON.stringify(service.item))
        return false;
      return true;
    }
    
    // add item

    service.newItem = function(item) {
      service.item = {}
      service.item.id = item.id;
      service.item.options = {};
      service.item.options.upgrades = {}
      service.item.options.sshkey = ""
      service.item.subscription = "monthly"
      service.initialiseItemUpgrades();
      saveCart();
    };

    service.clearItem = function() {
      service.item = {};
      saveCart();
    };
 
    service.addItem = function() {
      service.cart.push(service.item);
      service.item = {};
      saveCart();
    }; 

    service.getCurrentItemId = function() {
      return service.item.id;
    }

    service.initialiseItemUpgrades = function() {
      var id = service.getCurrentItemId();
      var product = productService.getProductById(id);
      for (var type in product.config.upgrades) {
        var upgrade = product.config.upgrades[type];
        service.item.options.upgrades[type] = {enabled : false}
      }
    }

    service.toggleItemUpgrade = function(type) {
      if (service.productHasUpgrade(type)) {
        service.item.options.upgrades[type].enabled = !service.item.options.upgrades[type].enabled
        saveCart();
      }
    }

    service.itemHasUpgrade = function(type) {
      if (service.productHasUpgrade(type)) {
        return service.item.options.upgrades[type].enabled
      }
      return false;
    }

    service.productHasUpgrade = function(type) {
      var id = service.getCurrentItemId();
      var product = productService.getProductById(id);
      if (typeof product.config.upgrades[type] != 'undefined')
        return true;
      return false;
    }

    service.setItemOS = function(os) {
      service.item.options.os = os;
      saveCart();
    };

    service.priceCart = function() {
      var total = 0
      for (var i in service.cart) {
        var config = service.getItemConfig(service.cart[i])
        total += config.price
      }
      return total;
    }

    service.getItemConfig = function(item) {
      var id = item.id;
      var product = productService.getProductById(id);
      var config = {}
      config.name = product.name;
      config.type = product.type;
      config.ram = product.config.ram;
      config.cpu = product.config.cpu;
      config.storage = product.config.storage;
      config.storagetype = product.config.storagetype;
      config.os = item.options.os;
      config.price = product.prices.monthly;

      for (var type in item.options.upgrades) {
        if (item.options.upgrades[type].enabled == true) {
          config.price += product.config.upgrades[type].prices.monthly;
          if (type == "hdd") {
            config.storagetype = type;
            config.storage = product.config.upgrades[type].quantity;
          } else {
            config[type] += product.config.upgrades[type].quantity;
          }
        }
      }
      return config;
    }

    service.getOsStr = function(os) {
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

    service.getItemSummary = function(i) {
      if (i < service.cartSize()) {
      var item = service.cart[i];
      var product = productService.getProductById(item.id);
      return product.name;
      } else {
        return "";
      }
    }

    service.deleteItem = function(i) {
      service.cart.splice(i, 1);
      saveCart();
    }

    service.emptyCart = function() {
      return service.cart.length == 0;
    } 
    return service; 
  })

  .factory('accountService', function($http) {
    var service = {};

    service.register = function(email, password) {
      var callback = function(data, status, headers, config) {
        console.log(data);
        service.success = data.success;
      };
      return $http.post('/register', "", {params:{username:email, password:password}}).success(callback);
    }
 
    service.login = function(email, password) {
      var callback = function(data, status, headers, config) {
        service.success = data.success;
      };
      return $http.post('/login', "", {params:{username:email, password:password}}).success(callback);
    };

    service.logout = function() {
      var callback = function(data, status, headers, config) {
      };
      return $http.get('/logout').success(callback);
    };

    service.isLoggedIn = function() {
      var callback = function(data, status, headers, config) {
        if (data == "true") {
          service.loggedIn = true;
        } else {
          service.loggedIn = false;
        }
      };
      return $http.get('/loggedin').success(callback);
    }
     return service;
  })

  .factory('productService', function($http) {
    var service = {};

    // filter and return products of type
    service.getProductsByType = function(type) {
      var res = []
      for (var i in service.products) {
        if (service.products[i].type == type)
          res.push(service.products[i]);
      }
      return res;
    }

    // get product given a product id
    service.getProductById = function(id) {
      for (var i in service.products) {
        if (service.products[i].id == id)
          return service.products[i];
      }
      return {error : "not found"};
    }

    // find waab product by name
    service.getWaabByName = function(name) {
      var waabs = service.getProductsByType("waab");
      for (var i in waabs) {
        if (waabs[i].name == name)
          return waabs[i];
      }
      return {error:"not found"};
    }

    // get available upgrades for product of id

    service.getWaabUpgrades = function(id) {
      var waab = service.getProductById(id);
      // must be a waab
      if (waab.type == "waab") {
        return waab.config.upgrades;
      }
    }

    var callback = function(data, status, headers, config) {
      service.products = data;
    }

    service.promise = $http.get('/products').success(callback);

    // get product info from server and present to client
    // lookup by name and id

    return service;
  })


  .factory('checkoutService', function(cartService, accountService, productService, $http, $location) {
    var service = {}
    // send payment to server
    // query for payment
  
    service.bitcoinPayment = function() {
      var cart = cartService.cart;
      if (cartService.emptyCart()) {
        // return redirect error
        $location.path("/waabCloudHosting");
      }
      if (cartService.validateCart()) {
        // send cart to server and get response
        var callback = function(data, status, headers, config) {
          if (data.error == "invalid request") {
            service.paymentSent = false;
          } else {
            service.paymentSent = true;
            service.paymentData = data.data;
          }

        };
        return $http.post("/checkout", JSON.stringify(cart), {withCredentials:true, params:{bitcoin:true}}).success(callback);
      } else {
        // delete cart and send client to main page
      }

    }; 

    service.paypalPayment = function() {
      // get cart
      var cart = cartService.cart;
      if (cartService.emptyCart()) {
        // return redirect error
        return {error : "empty cart"};
      }

      // verify cart
      if (cartService.validateCart()) {
        // send cart to server and get response
        var callback = function(data, status, headers, config) {
          if (data.error == "invalid request") {
            service.paymentSent = false;
          } else {
            service.paymentSent = true;
            service.paymentData = data.data;
          }
        };
        return $http.post("/checkout", JSON.stringify(cart), {withCredentials:true, params:{paypal:true}}).success(callback);
      } else {
        cartService.destroyCart();
        return {error : "invalid cart"};
        // delete cart and send client to main page
      }
    }

    return service;
  })

  .factory('domainService', ['$location', '$http', function($location, $http) {
    var domainService = {};

    return domainService; 
  }])

  .factory('validationService', ['$http', function($location, $http) {
    var validationService = {};
    
    validationService.validateSSHKey = function(key) {
       var xhr = new XMLHttpRequest();
       xhr.open("POST", "/ssh-validate" , false);
       xhr.send(key);
       var data = JSON.parse(xhr.responseText);
       return data.valid == true;
    }; 
    return validationService;
  }])


  .factory('checkPaymentService', function($http) {
    var service = {};
    service.checkPayment = function(id) {
      var callback = function(data,status,headers, config) {
        console.log(data);
        if (typeof data.error == 'undefined') {
          service.state = data.state;
        }
      };
      return $http.get('/checkpayment', {params:{id:id}}).success(callback);
    };
    return service;
  })

  .factory('soldOutService', ['$http', function($http) {
    var service = {}; 
    service.soldOut = false;
    service.checkSoldOut = function() {
      var callback = function(data, status, headers, config) {
        if (data == "yes")
          service.soldOut = true;
      }
      return $http.get('/soldout').success(callback);
    }

    return service;
  }])

  .factory('pingService', function($http) {
    var service = {}
    service.ping = function(page) {
      $http.get("/" + page);
    }
    return service;
  });

;
