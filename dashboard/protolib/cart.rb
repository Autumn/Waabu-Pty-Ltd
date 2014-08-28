require 'couchrest'


module Waabu
  class Cart
    PRODUCTS_DB = CouchRest.database "http://172.24.0.7:5984/devel_products"

    CART = []

    # CART ======================================================= 

    def self.get_products
      products = []
      PRODUCTS_DB.view("search/id")["rows"].each do |row|
	item = {}
	products.push row["value"] if not row["id"].match /^_design/
      end
      products
    end

    def self.search_product id
      product = nil
      PRODUCTS_DB.view("search/id")["rows"].each do |row|
	product = row["value"] if id == row["key"]
      end
      product
    end

    def self.get_upgrades item
      product = self.search_product item[:id]
      product["config"]["upgrades"]
    end

    def self.get_item i
      products = self.get_products
      item = {}
      item[:id] = products[i]["id"]
      item[:options] = {}
      item[:options][:upgrades] = {}
      item[:subscription] = ""
      item
    end

    def self.set_opts item, type, value
      item[:options][type] = value
    end

    def self.set_upgrade item, type
      upgrades = self.get_upgrades item
      item[:options][:upgrades][type] = true if upgrades[type] != nil
    end

    def self.set_subscription item, term
      item[:subscription] = term
    end

    def self.add_item item
      # item must have subscription
      CART.push item
    end

    # CHECKOUT ================================================== 

    def verify_cart cart

    end

    def self.price_cart cart
      total = 0
      cart.each do |item|
	total += self.price_item item
      end 
      total
    end

    def self.price_item item
      product = self.search_product item["id"]
      price = 0
      price += product["prices"][item["subscription"]]
      item["options"]["upgrades"].each_key do |type|
	price += product["config"]["upgrades"][type]["prices"][item["subscription"]] if item["options"]["upgrades"][type]["enabled"] == true
      end
      price
    end
  end
end
