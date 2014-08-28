require 'couchrest'
require 'securerandom'

module Waabu
  class Products
    PRODUCTS_DB = CouchRest.database! "http://172.24.0.7:5984/products_prod"

    def self.bootstrap_db
    # create views

      search = {
	"type"=> {"map"=>"function(doc){if(doc.type){emit(doc.type,doc);}}"}, 
	"name"=> {"map"=>"function(doc){if(doc.name){emit(doc.name,doc);}}"}, 
	"id"=> {"map"=>"function(doc){if(doc.id){emit(doc.id,doc);}}"}
      }

      view = {"_id"=>"_design/search", "views"=>search}

      PRODUCTS_DB.save_doc view
      
      # basewaab
      price = self.create_prices [["monthly", 9], ["yearly", 108]]
      upgrades = self.create_upgrades [["cpu", [["monthly", 3], ["yearly", 36]], 1], ["hdd", [["monthly", 5], ["yearly", 60]], 30]]
      conf = self.create_vm_conf 2, 512, 10, "ssd", upgrades
      self.store_product(self.create_product "BaseWaab", "waab", price, conf)

      # corewaab
      price = self.create_prices [["monthly", 18],["yearly", 216]]
      upgrades = self.create_upgrades [["cpu", [["monthly", 3], ["yearly", 36]], 1], ["hdd", [["monthly", 5], ["yearly", 60]], 50]]
      conf = self.create_vm_conf 2, 1024, 20, "ssd", upgrades
      self.store_product(self.create_product "CoreWaab", "waab", price, conf)

      # devwaab 
      price = self.create_prices [["monthly", 35], ["yearly", 420]]
      upgrades = self.create_upgrades [["cpu", [["monthly", 5], ["yearly", 60]], 2], ["hdd", [["monthly", 10], ["yearly", 120]], 100]]
      conf = self.create_vm_conf 3, 2048, 30, "ssd", upgrades
      self.store_product(self.create_product "DevWaab", "waab", price, conf)

      # cloudwaab

      price = self.create_prices [["monthly", 60], ["yearly", 720]]
      upgrades = self.create_upgrades [["cpu", [["monthly", 5], ["yearly", 60]], 2], ["hdd", [["monthly", 20], ["yearly", 240]], 200]]
      conf = self.create_vm_conf 4, 4096, 30, "ssd", upgrades
      self.store_product(self.create_product "CloudWaab", "waab", price, conf)

      # powerwaab

      price = self.create_prices [["monthly", 130], ["yearly", 1560]]
      upgrades = self.create_upgrades [["ram", [["monthly", 60], ["yearly", 720]], 4096], ["hdd", [["monthly", 40], ["yearly", 480]], 500]]
      conf = self.create_vm_conf 8, 8192, 80, "ssd", upgrades
      self.store_product(self.create_product "PowerWaab", "waab", price, conf)

      # check data

      # each product should have a monthly and yearly price
      # each upgrade needs a monthly and yearly price
      # each product needs a set of fields
      # each upgrade needs a set of fields

    end

    def self.clean_db
      PRODUCTS_DB.get("_all_docs")["rows"].each do |row|
	PRODUCTS_DB.delete_doc({"_id"=>row["id"], "_rev"=>row["value"]["rev"]})
      end
    end

    def self.create_product name, type, prices, config
      product = {}
      product[:id] = SecureRandom.uuid
      product[:name] = name
      product[:type] = type
      product[:prices] = prices
      product[:config] = config
      product
    end

    def self.store_product product
      PRODUCTS_DB.save_doc product
    end

    def self.create_prices values
      prices = {}
      values.map do |pair|
	prices[pair[0]] = pair[1]
    #    create_price pair[0], pair[1]
      end
      prices
    end

    def self.create_price term, price
      {:term => term, :price => price}
    end

    def self.create_upgrades upgrades
      upgrades.map do |upgrade|
	create_upgrade upgrade[0], create_prices(upgrade[1]), upgrade[2]
      end
    end

    def self.create_upgrade type, prices, quantity
      {:type => type, :prices => prices, :quantity => quantity}
    end

    def self.create_vm_conf cpu, ram, storage, storagetype, upgrades
      config = {:cpu => cpu, :ram => ram, :storage => storage, :storagetype => storagetype, :upgrades => {}}
      upgrades.each do |upgrade|
	type = upgrade[:type].to_sym
	config[:upgrades][type] = {}
	config[:upgrades][type][:prices] = upgrade[:prices]
	config[:upgrades][type][:quantity] = upgrade[:quantity]
      end
      config
    end

    def self.register_product user, product, config, term
      
    end
  end
end
